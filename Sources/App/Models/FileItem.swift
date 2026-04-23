import Foundation

struct FileItem: Identifiable, Hashable {
    enum ImportSource: Hashable {
        case directFile
        case folder(rootURL: URL)
    }

    let id: UUID
    var url: URL
    var accessURL: URL
    var isSelected: Bool
    var importSource: ImportSource

    init(
        id: UUID = UUID(),
        url: URL,
        accessURL: URL? = nil,
        isSelected: Bool = true,
        importSource: ImportSource = .directFile
    ) {
        self.id = id
        self.url = url
        self.accessURL = accessURL ?? url
        self.isSelected = isSelected
        self.importSource = importSource
    }

    var originalFilename: String {
        url.lastPathComponent
    }

    var originalExtension: String {
        url.pathExtension
    }

    var originalBaseName: String {
        let filename = originalFilename
        let ext = originalExtension

        guard !ext.isEmpty else {
            return filename
        }

        return String(filename.dropLast(ext.count + 1))
    }

    var directoryURL: URL {
        url.deletingLastPathComponent()
    }

    var modificationDate: Date? {
        try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
    }

    var addedDate: Date? {
        try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
    }

    var needsDirectoryAccessGrant: Bool {
        !directoryURL.isEqualToOrContained(in: accessURL)
    }

    var displayDirectory: String {
        directoryURL.path(percentEncoded: false)
    }
}

extension URL {
    func isEqualToOrContained(in parentURL: URL) -> Bool {
        let path = standardizedFileURL.path(percentEncoded: false)
        let parentPath = parentURL.standardizedFileURL.path(percentEncoded: false)

        if path == parentPath {
            return true
        }

        let parentDirectoryPath = parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
        return path.hasPrefix(parentDirectoryPath)
    }
}
