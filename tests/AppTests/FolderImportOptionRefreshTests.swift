@testable import Renami
import XCTest

@MainActor
final class FolderImportOptionRefreshTests: XCTestCase {
    func testChangingFileTypeFilterRebuildsExistingFolderImport() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let imageFile = root.appendingPathComponent("bild.png")
        let documentFile = root.appendingPathComponent("text.pdf")
        try "png".write(to: imageFile, atomically: true, encoding: .utf8)
        try "pdf".write(to: documentFile, atomically: true, encoding: .utf8)

        let viewModel = AppViewModel()
        viewModel.files = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: false, fileTypeFilter: .allFiles)
        )
        viewModel.setFolderFileTypeFilter(.images)

        XCTAssertEqual(viewModel.files.map(\.originalFilename), ["bild.png"])
    }

    func testChangingSubfolderOptionRebuildsExistingFolderImport() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let nestedFolder = root.appendingPathComponent("Unterordner", isDirectory: true)
        try FileManager.default.createDirectory(at: nestedFolder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let topFile = root.appendingPathComponent("top.txt")
        let nestedFile = nestedFolder.appendingPathComponent("nested.txt")
        try "top".write(to: topFile, atomically: true, encoding: .utf8)
        try "nested".write(to: nestedFile, atomically: true, encoding: .utf8)

        let viewModel = AppViewModel()
        viewModel.files = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: false, fileTypeFilter: .allFiles)
        )
        viewModel.setIncludesSubfolders(true)

        XCTAssertEqual(Set(viewModel.files.map(\.originalFilename)), ["top.txt", "nested.txt"])
    }
}
