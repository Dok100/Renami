import AppKit
import Foundation

enum FileImportService {
    enum FileTypeFilter: String, CaseIterable, Hashable {
        case allFiles
        case images
        case documents
        case spreadsheets
        case presentations
        case audio
        case video
        case archives

        var title: String {
            switch self {
            case .allFiles:
                "Alle Dateien"
            case .images:
                "Bilder"
            case .documents:
                "Dokumente"
            case .spreadsheets:
                "Tabellen"
            case .presentations:
                "Präsentationen"
            case .audio:
                "Audio"
            case .video:
                "Video"
            case .archives:
                "Archive"
            }
        }

        fileprivate var allowedExtensions: Set<String>? {
            switch self {
            case .allFiles:
                nil
            case .images:
                ["jpg", "jpeg", "png", "webp", "gif", "heic", "svg"]
            case .documents:
                ["pdf", "doc", "docx", "txt", "rtf", "md", "pages"]
            case .spreadsheets:
                ["xls", "xlsx", "csv", "tsv", "numbers"]
            case .presentations:
                ["ppt", "pptx", "key"]
            case .audio:
                ["mp3", "wav", "m4a", "aac", "flac"]
            case .video:
                ["mp4", "mov", "m4v", "avi", "mkv"]
            case .archives:
                ["zip", "rar", "7z", "tar", "gz"]
            }
        }
    }

    struct ImportOptions: Hashable {
        var includesSubfolders: Bool = false
        var fileTypeFilter: FileTypeFilter = .allFiles
    }

    private struct ImportedEntry: Hashable {
        let fileURL: URL
        let accessURL: URL
        let importSource: FileItem.ImportSource
    }

    private static let ignoredFilenames: Set<String> = [
        ".DS_Store",
        "Thumbs.db",
    ]

    @MainActor
    static func pickFiles() -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.prompt = "Hinzufügen"
        return panel.runModal() == .OK ? panel.urls : []
    }

    @MainActor
    static func pickFolders() -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.prompt = "Ordner hinzufügen"
        return panel.runModal() == .OK ? panel.urls : []
    }

    @MainActor
    static func pickAccessFolders(for directories: [URL]) -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.prompt = "Ordnerzugriff erlauben"
        panel.message = "Bitte die Zielordner der ausgewählten Dateien freigeben, damit Renami die Dateien umbenennen kann."

        if let firstDirectory = directories.first {
            panel.directoryURL = firstDirectory
        }

        return panel.runModal() == .OK ? panel.urls : []
    }

    static func buildFileItems(from urls: [URL], options: ImportOptions = ImportOptions()) -> [FileItem] {
        let expanded = urls.flatMap { flattenImportURL($0, options: options) }
        let deduplicated = Dictionary(grouping: expanded, by: \.fileURL.standardizedFileURL)
            .compactMap(\.value.first)
            .sorted { $0.fileURL.lastPathComponent.localizedCaseInsensitiveCompare($1.fileURL.lastPathComponent) == .orderedAscending }

        return deduplicated.map { entry in
            FileItem(
                url: entry.fileURL,
                accessURL: entry.accessURL,
                importSource: entry.importSource
            )
        }
    }

    private static func flattenImportURL(_ url: URL, options: ImportOptions) -> [ImportedEntry] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) else {
            return []
        }

        if !isDirectory.boolValue {
            return [ImportedEntry(fileURL: url, accessURL: url, importSource: .directFile)]
        }

        if options.includesSubfolders {
            return recursivelyImportedEntries(in: url, options: options)
        }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .isHiddenKey, .nameKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return contents.compactMap { item in
            guard shouldImport(item, options: options),
                  (try? item.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
            else {
                return nil
            }

            return ImportedEntry(
                fileURL: item,
                accessURL: url,
                importSource: .folder(rootURL: url)
            )
        }
    }

    private static func recursivelyImportedEntries(in rootURL: URL, options: ImportOptions) -> [ImportedEntry] {
        let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey, .isHiddenKey, .nameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )

        let items = (enumerator?.allObjects as? [URL]) ?? []
        return items.compactMap { item in
            guard shouldImport(item, options: options),
                  (try? item.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
            else {
                return nil
            }

            return ImportedEntry(
                fileURL: item,
                accessURL: rootURL,
                importSource: .folder(rootURL: rootURL)
            )
        }
    }

    private static func shouldImport(_ item: URL, options: ImportOptions) -> Bool {
        let resourceValues = try? item.resourceValues(forKeys: [.isHiddenKey, .nameKey])
        let filename = resourceValues?.name ?? item.lastPathComponent

        if resourceValues?.isHidden == true || ignoredFilenames.contains(filename) {
            return false
        }

        guard let allowedExtensions = options.fileTypeFilter.allowedExtensions else {
            return true
        }

        return allowedExtensions.contains(item.pathExtension.lowercased())
    }
}
