import Foundation

struct RenameOperation: Hashable {
    let fileID: UUID
    let originalURL: URL
    let renamedURL: URL
    let accessURL: URL
    let isSelected: Bool
    let importSource: FileItem.ImportSource
}

struct UndoRenameSession: Hashable {
    let operations: [RenameOperation]
    let createdAt: Date

    var renamedCount: Int {
        operations.count
    }
}

struct RenameExecutionResult {
    let succeededIDs: Set<UUID>
    let succeededOperations: [RenameOperation]
    let failures: [UUID: String]
}

struct UndoExecutionResult {
    let restoredIDs: Set<UUID>
    let restoredOperations: [RenameOperation]
    let failures: [UUID: String]
}

enum RenameExecutor {
    static func execute(previews: [PreviewItem]) -> RenameExecutionResult {
        let eligible = previews.filter { $0.isSelected && !$0.hasErrors && $0.isChanged }
        var succeededIDs = Set<UUID>()
        var succeededOperations: [RenameOperation] = []
        var failures: [UUID: String] = [:]

        for preview in eligible {
            do {
                try withSecurityScopedAccess(to: accessURLs(for: preview)) {
                    try withSecurityScopedAccess(to: preview.source.url) {
                        try FileManager.default.moveItem(at: preview.source.url, to: preview.targetURL)
                    }
                }
                succeededIDs.insert(preview.id)
                succeededOperations.append(
                    RenameOperation(
                        fileID: preview.id,
                        originalURL: preview.source.url,
                        renamedURL: preview.targetURL,
                        accessURL: preview.source.accessURL,
                        isSelected: preview.source.isSelected,
                        importSource: preview.source.importSource
                    )
                )
            } catch {
                failures[preview.id] = failureMessage(for: error)
            }
        }

        return RenameExecutionResult(
            succeededIDs: succeededIDs,
            succeededOperations: succeededOperations,
            failures: failures
        )
    }

    static func undo(session: UndoRenameSession) -> UndoExecutionResult {
        var restoredIDs = Set<UUID>()
        var restoredOperations: [RenameOperation] = []
        var failures: [UUID: String] = [:]

        for operation in session.operations.reversed() {
            do {
                try withSecurityScopedAccess(to: accessURLs(for: operation)) {
                    try withSecurityScopedAccess(to: operation.renamedURL) {
                        try FileManager.default.moveItem(at: operation.renamedURL, to: operation.originalURL)
                    }
                }
                restoredIDs.insert(operation.fileID)
                restoredOperations.append(operation)
            } catch {
                failures[operation.fileID] = failureMessage(for: error)
            }
        }

        return UndoExecutionResult(
            restoredIDs: restoredIDs,
            restoredOperations: restoredOperations,
            failures: failures
        )
    }

    private static func accessURLs(for preview: PreviewItem) -> [URL] {
        let candidates = [
            preview.source.accessURL,
            preview.source.url,
            preview.source.directoryURL,
            preview.targetURL,
            preview.targetURL.deletingLastPathComponent(),
        ]

        var seen = Set<URL>()
        return candidates.compactMap { url in
            let standardized = url.standardizedFileURL
            guard !seen.contains(standardized) else {
                return nil
            }
            seen.insert(standardized)
            return standardized
        }
    }

    private static func accessURLs(for operation: RenameOperation) -> [URL] {
        let candidates = [
            operation.accessURL,
            operation.originalURL,
            operation.originalURL.deletingLastPathComponent(),
            operation.renamedURL,
            operation.renamedURL.deletingLastPathComponent(),
        ]

        var seen = Set<URL>()
        return candidates.compactMap { url in
            let standardized = url.standardizedFileURL
            guard !seen.contains(standardized) else {
                return nil
            }
            seen.insert(standardized)
            return standardized
        }
    }

    private static func withSecurityScopedAccess<T>(to url: URL, operation: () throws -> T) throws -> T {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try operation()
    }

    private static func withSecurityScopedAccess<T>(to urls: [URL], operation: () throws -> T) throws -> T {
        let accessedURLs = urls.filter { $0.startAccessingSecurityScopedResource() }
        defer {
            for url in accessedURLs.reversed() {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try operation()
    }

    private static func failureMessage(for error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == NSCocoaErrorDomain,
           nsError.code == NSFileWriteNoPermissionError
        {
            return "Keine Schreibberechtigung für den Zielordner. Wenn der Fehler bleibt, bitte den Ordner statt einzelner Dateien importieren."
        }

        return nsError.localizedDescription
    }
}
