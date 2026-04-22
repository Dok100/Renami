import Foundation

struct FileItem: Identifiable, Hashable {
    let id: UUID
    var url: URL
    var accessURL: URL
    var isSelected: Bool

    init(id: UUID = UUID(), url: URL, accessURL: URL? = nil, isSelected: Bool = true) {
        self.id = id
        self.url = url
        self.accessURL = accessURL ?? url
        self.isSelected = isSelected
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
        accessURL.standardizedFileURL != directoryURL.standardizedFileURL
    }

    var displayDirectory: String {
        directoryURL.path(percentEncoded: false)
    }
}
