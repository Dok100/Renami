@testable import Renami
import XCTest

@MainActor
final class RuleReorderingTests: XCTestCase {
    func testMoveRuleBeforeChangesUnderlyingRuleOrder() throws {
        let viewModel = AppViewModel()
        let originalRules = viewModel.rules

        let dateRuleID = try XCTUnwrap(originalRules.first(where: { $0.kind == .dateStamp })?.id)
        let prefixRuleID = try XCTUnwrap(originalRules.first(where: { $0.kind == .prefix })?.id)

        viewModel.moveRule(dateRuleID, before: prefixRuleID)

        let reorderedKinds = viewModel.rules.map(\.kind)
        let dateIndex = reorderedKinds.firstIndex(of: .dateStamp)
        let prefixIndex = reorderedKinds.firstIndex(of: .prefix)

        XCTAssertNotNil(dateIndex)
        XCTAssertNotNil(prefixIndex)
        XCTAssertLessThan(try XCTUnwrap(dateIndex), try XCTUnwrap(prefixIndex))
    }

    func testPreviewUsesUpdatedRuleOrderAfterMove() {
        let viewModel = AppViewModel()
        viewModel.files = [
            FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt")),
        ]

        guard let findReplaceIndex = viewModel.rules.firstIndex(where: { $0.kind == .findReplace }),
              let prefixIndex = viewModel.rules.firstIndex(where: { $0.kind == .prefix }),
              let findReplaceRuleID = viewModel.rules.first(where: { $0.kind == .findReplace })?.id
        else {
            return XCTFail("Expected find/replace and prefix rules")
        }

        viewModel.rules[findReplaceIndex].isEnabled = true
        viewModel.rules[findReplaceIndex].textValue = "sample"
        viewModel.rules[findReplaceIndex].secondaryTextValue = "file"
        viewModel.rules[prefixIndex].isEnabled = true
        viewModel.rules[prefixIndex].textValue = "sample_"

        XCTAssertEqual(viewModel.previews.first?.targetFilename, "sample_file.txt")

        viewModel.moveRuleDown(findReplaceRuleID)

        XCTAssertEqual(viewModel.previews.first?.targetFilename, "file_file.txt")
    }
}
