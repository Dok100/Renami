import Foundation

struct RenameExecutionResult {
    let succeededIDs: Set<UUID>
    let failures: [UUID: String]
}

enum RenameExecutor {
    static func execute(previews: [PreviewItem]) -> RenameExecutionResult {
        let eligible = previews.filter { $0.isSelected && !$0.hasErrors && $0.isChanged }
        var succeededIDs = Set<UUID>()
        var failures: [UUID: String] = [:]

        for preview in eligible {
            do {
                try withSecurityScopedAccess(to: accessURLs(for: preview)) {
                    try withSecurityScopedAccess(to: preview.source.url) {
                        try FileManager.default.moveItem(at: preview.source.url, to: preview.targetURL)
                    }
                }
                succeededIDs.insert(preview.id)
            } catch {
                failures[preview.id] = failureMessage(for: error)
            }
        }

        return RenameExecutionResult(succeededIDs: succeededIDs, failures: failures)
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
