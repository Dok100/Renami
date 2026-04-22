@testable import Renami
import XCTest

@MainActor
final class UndoRenameTests: XCTestCase {
    func testUndoRestoresLastRenamedFile() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let sourceURL = directory.appendingPathComponent("bericht.txt")
        try "inhalt".write(to: sourceURL, atomically: true, encoding: .utf8)

        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: sourceURL, accessURL: directory),
        ]
        viewModel.rules = [
            RenameRule(kind: .prefix, isEnabled: true, textValue: "Neu_"),
        ]

        viewModel.requestRename()
        waitForAsyncFileMove()

        let renamedURL = directory.appendingPathComponent("Neu_bericht.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: renamedURL.path(percentEncoded: false)))
        XCTAssertTrue(viewModel.canUndoLastRename)

        viewModel.undoLastRename()
        waitForAsyncFileMove()

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path(percentEncoded: false)))
        XCTAssertFalse(FileManager.default.fileExists(atPath: renamedURL.path(percentEncoded: false)))
        XCTAssertEqual(viewModel.files.first?.url.lastPathComponent, "bericht.txt")
        XCTAssertFalse(viewModel.canUndoLastRename)
    }

    private func waitForAsyncFileMove() {
        let expectation = XCTestExpectation(description: "Async Dateioperation abgeschlossen")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
