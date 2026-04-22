@testable import Renami
import XCTest

@MainActor
final class SourceListModeTests: XCTestCase {
    func testChangedOnlyFilterShowsOnlyChangedFilesInLeftList() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .prefix, isEnabled: true, textValue: "Neu_"),
        ]
        viewModel.files[1].isSelected = false
        viewModel.sourceListMode = .changedOnly

        let displayed = viewModel.displayedSourcePreviews

        XCTAssertEqual(displayed.map(\.source.originalFilename), ["alpha.txt", "beta.txt"])
        XCTAssertTrue(displayed.allSatisfy(\.isChanged))
    }

    func testConflictsOnlyFilterShowsOnlyConflictingFilesInLeftList() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/alpha.txt")),
            FileItem(url: URL(fileURLWithPath: "/tmp/beta.txt")),
        ]
        viewModel.rules = [
            RenameRule(kind: .findReplace, isEnabled: true, textValue: "alpha", secondaryTextValue: ""),
        ]
        viewModel.sourceListMode = .conflictsOnly

        let displayed = viewModel.displayedSourcePreviews

        XCTAssertEqual(displayed.count, 1)
        XCTAssertEqual(displayed.first?.source.originalFilename, "alpha.txt")
        XCTAssertTrue(displayed.first?.hasErrors == true)
    }
}
