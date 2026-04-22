@testable import Renami
import XCTest

@MainActor
final class PreviewListModeTests: XCTestCase {
    func testAllModePlacesConflictsThenChangedThenUnchanged() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .findReplace, isEnabled: true, textValue: "alpha", secondaryTextValue: ""),
        ]
        viewModel.previewListMode = .all

        let displayed = viewModel.displayedPreviews

        XCTAssertEqual(displayed.map(\.source.originalFilename), ["alpha.txt", "beta.txt"])
        XCTAssertTrue(displayed.first?.hasErrors == true)
        XCTAssertTrue(displayed.last?.isChanged == false)
    }

    func testChangedOnlyModeFiltersUnchangedEntries() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .prefix, isEnabled: false, textValue: "X_"),
        ]
        viewModel.previewListMode = .changedOnly

        XCTAssertTrue(viewModel.displayedPreviews.isEmpty)
    }

    func testConflictsOnlyModeFiltersToErrors() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .findReplace, isEnabled: true, textValue: "alpha", secondaryTextValue: ""),
        ]
        viewModel.previewListMode = .conflictsOnly

        let displayed = viewModel.displayedPreviews

        XCTAssertEqual(displayed.count, 1)
        XCTAssertEqual(displayed.first?.source.originalFilename, "alpha.txt")
        XCTAssertTrue(displayed.first?.hasErrors == true)
    }
}
