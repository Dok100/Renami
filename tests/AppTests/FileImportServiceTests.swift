@testable import Renami
import XCTest

final class FileImportServiceTests: XCTestCase {
    func testFlatFolderImportOnlyLoadsTopLevelFiles() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let topFile = root.appendingPathComponent("top.txt")
        let nestedFolder = root.appendingPathComponent("Unterordner", isDirectory: true)
        let nestedFile = nestedFolder.appendingPathComponent("nested.txt")

        try FileManager.default.createDirectory(at: nestedFolder, withIntermediateDirectories: true)
        try "top".write(to: topFile, atomically: true, encoding: .utf8)
        try "nested".write(to: nestedFile, atomically: true, encoding: .utf8)

        let items = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: false, fileTypeFilter: .allFiles)
        )

        XCTAssertEqual(items.map(\.originalFilename), ["top.txt"])
    }

    func testRecursiveFolderImportLoadsNestedFiles() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let topFile = root.appendingPathComponent("top.txt")
        let nestedFolder = root.appendingPathComponent("Unterordner", isDirectory: true)
        let nestedFile = nestedFolder.appendingPathComponent("nested.txt")

        try FileManager.default.createDirectory(at: nestedFolder, withIntermediateDirectories: true)
        try "top".write(to: topFile, atomically: true, encoding: .utf8)
        try "nested".write(to: nestedFile, atomically: true, encoding: .utf8)

        let items = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: true, fileTypeFilter: .allFiles)
        )

        XCTAssertEqual(Set(items.map(\.originalFilename)), ["top.txt", "nested.txt"])
        XCTAssertTrue(items.allSatisfy { $0.accessURL.standardizedFileURL == root.standardizedFileURL })
    }

    func testFolderImportAppliesFileTypeFilter() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let imageFile = root.appendingPathComponent("bild.png")
        let documentFile = root.appendingPathComponent("text.pdf")

        try "png".write(to: imageFile, atomically: true, encoding: .utf8)
        try "pdf".write(to: documentFile, atomically: true, encoding: .utf8)

        let items = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: false, fileTypeFilter: .images)
        )

        XCTAssertEqual(items.map(\.originalFilename), ["bild.png"])
    }

    func testFolderImportIgnoresHiddenAndSystemFiles() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let visibleFile = root.appendingPathComponent("sichtbar.txt")
        let hiddenFile = root.appendingPathComponent(".versteckt.txt")
        let systemFile = root.appendingPathComponent(".DS_Store")

        try "ok".write(to: visibleFile, atomically: true, encoding: .utf8)
        try "hidden".write(to: hiddenFile, atomically: true, encoding: .utf8)
        try "system".write(to: systemFile, atomically: true, encoding: .utf8)

        let items = FileImportService.buildFileItems(
            from: [root],
            options: .init(includesSubfolders: false, fileTypeFilter: .allFiles)
        )

        XCTAssertEqual(items.map(\.originalFilename), ["sichtbar.txt"])
    }

    func testDirectFileImportIsKeptEvenWhenFolderFilterWouldExcludeIt() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let directFile = root.appendingPathComponent("text.pdf")
        try "pdf".write(to: directFile, atomically: true, encoding: .utf8)

        let items = FileImportService.buildFileItems(
            from: [directFile],
            options: .init(includesSubfolders: true, fileTypeFilter: .images)
        )

        XCTAssertEqual(items.map(\.originalFilename), ["text.pdf"])
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
