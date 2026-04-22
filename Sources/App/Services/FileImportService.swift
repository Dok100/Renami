import AppKit
import Foundation

enum FileImportService {
    private struct ImportedEntry: Hashable {
        let fileURL: URL
        let accessURL: URL
    }

    static func pickFiles() -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.prompt = "Hinzufügen"
        return panel.runModal() == .OK ? panel.urls : []
    }

    static func pickFolders() -> [URL] {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.prompt = "Ordner hinzufügen"
        return panel.runModal() == .OK ? panel.urls : []
    }

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

    static func buildFileItems(from urls: [URL]) -> [FileItem] {
        let expanded = urls.flatMap(flattenImportURL)
        let deduplicated = Dictionary(grouping: expanded, by: \.fileURL.standardizedFileURL)
            .compactMap(\.value.first)
            .sorted { $0.fileURL.lastPathComponent.localizedCaseInsensitiveCompare($1.fileURL.lastPathComponent) == .orderedAscending }

        return deduplicated.map { entry in
            FileItem(url: entry.fileURL, accessURL: entry.accessURL)
        }
    }

    private static func flattenImportURL(_ url: URL) -> [ImportedEntry] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) else {
            return []
        }

        if !isDirectory.boolValue {
            return [ImportedEntry(fileURL: url, accessURL: url)]
        }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return contents.compactMap { item in
            guard (try? item.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false else {
                return nil
            }

            return ImportedEntry(fileURL: item, accessURL: url)
        }
    }
}
