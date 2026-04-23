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

    func testRightPreviewOnlyShowsSelectedFiles() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt"), isSelected: false),
        ]
        viewModel.rules = [
            RenameRule(kind: .prefix, isEnabled: true, textValue: "Neu_"),
        ]
        viewModel.previewListMode = .all

        let displayed = viewModel.displayedPreviews

        XCTAssertEqual(displayed.map(\.source.originalFilename), ["alpha.txt"])
        XCTAssertEqual(viewModel.changedCount, 1)
        XCTAssertEqual(viewModel.renameCandidateCount, 1)
    }

    func testDeselectedConflictsDoNotBlockRenameApproval() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt"), isSelected: false),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .findReplace, isEnabled: true, textValue: "alpha", secondaryTextValue: ""),
            RenameRule(kind: .prefix, isEnabled: true, textValue: "Neu_"),
        ]
        viewModel.previewListMode = .conflictsOnly

        XCTAssertTrue(viewModel.displayedPreviews.isEmpty)
        XCTAssertEqual(viewModel.errorCount, 0)
        XCTAssertTrue(viewModel.canRename)
    }
}
