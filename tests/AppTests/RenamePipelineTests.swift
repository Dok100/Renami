@testable import Renami
import XCTest

final class RenamePipelineTests: XCTestCase {
    func testPipelineAppliesFindReplacePrefixAndSuffix() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/scan_01.txt"))
        let rules = [
            RenameRule(kind: .findReplace, isEnabled: true, textValue: "scan", secondaryTextValue: "invoice"),
            RenameRule(kind: .prefix, isEnabled: true, textValue: "2026_"),
            RenameRule(kind: .suffix, isEnabled: true, textValue: "_final"),
        ]

        let result = RenamePipeline.apply(baseName: "scan_01", rules: rules, context: RenameContext(itemIndex: 0, fileItem: file))

        XCTAssertEqual(result, "2026_invoice_01_final")
    }

    func testNumberingUsesStablePaddingAndStep() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/export.txt"))
        let rules = [
            RenameRule(
                kind: .numbering,
                isEnabled: true,
                numberStart: 3,
                numberStep: 2,
                numberPadding: 3,
                numberPosition: .suffix,
                separator: "_"
            ),
        ]

        let result = RenamePipeline.apply(baseName: "export", rules: rules, context: RenameContext(itemIndex: 2, fileItem: file))

        XCTAssertEqual(result, "export_007")
    }

    func testWindowsSanitizeReplacesReservedCharacters() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/report.txt"))
        let rules = [
            RenameRule(kind: .windowsSanitize, isEnabled: true, replaceReservedCharacters: true),
        ]

        let result = RenamePipeline.apply(baseName: "Report:Q1/2026*", rules: rules, context: RenameContext(itemIndex: 0, fileItem: file))

        XCTAssertEqual(result, "Report_Q1_2026_")
    }

    func testTitleCasePreservesDatePrefixAndSeparators() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/report.txt"))
        let rules = [
            RenameRule(kind: .caseTransform, isEnabled: true, caseStyle: .title),
        ]

        let result = RenamePipeline.apply(
            baseName: "2026-03-12_zinseszins_rechner",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-03-12_Zinseszins_Rechner")
    }

    func testDateStampDoesNotDuplicateAfterTitleCaseWhenDatePrefixAlreadyExists() throws {
        let manualDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/report.txt"))
        let rules = [
            RenameRule(kind: .caseTransform, isEnabled: true, caseStyle: .title),
            RenameRule(
                kind: .dateStamp,
                isEnabled: true,
                manualDate: manualDate,
                dateSource: .manual,
                datePosition: .prefix,
                onlyIfNoDatePrefixExists: true
            ),
        ]

        let result = RenamePipeline.apply(
            baseName: "2026-03-12_zinseszins_rechner",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-03-12_Zinseszins_Rechner")
    }
}
