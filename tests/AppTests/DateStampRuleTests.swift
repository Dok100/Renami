@testable import Renami
import XCTest

final class DateStampRuleTests: XCTestCase {
    func testManualDateStampUsesExpectedFormatAsPrefix() throws {
        let manualDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(kind: .dateStamp, isEnabled: true, manualDate: manualDate, dateSource: .manual, datePosition: .prefix),
        ]

        let result = RenamePipeline.apply(
            baseName: "sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-18_sample")
    }

    func testDateStampUsesModificationDateAsSuffix() throws {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".txt")
        XCTAssertTrue(FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil))

        let modificationDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        try FileManager.default.setAttributes([.modificationDate: modificationDate], ofItemAtPath: fileURL.path)

        let file = FileItem(url: fileURL)
        let rules = [
            RenameRule(kind: .dateStamp, isEnabled: true, dateSource: .modificationDate, datePosition: .suffix),
        ]

        let result = RenamePipeline.apply(
            baseName: "sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "sample2026-04-18_")

        try? FileManager.default.removeItem(at: fileURL)
    }

    func testDateStampSkipsExistingPrefixWhenProtectionIsEnabled() throws {
        let manualDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
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
            baseName: "2026-04-10_sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-10_sample")
    }

    func testDateStampCanOverwriteExistingPrefixProtectionWhenDisabled() throws {
        let manualDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(
                kind: .dateStamp,
                isEnabled: true,
                manualDate: manualDate,
                dateSource: .manual,
                datePosition: .prefix,
                onlyIfNoDatePrefixExists: false
            ),
        ]

        let result = RenamePipeline.apply(
            baseName: "2026-04-10_sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-18_2026-04-10_sample")
    }

    func testNormalizeDatePrefixConvertsDayMonthYearFormat() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(kind: .normalizeDatePrefix, isEnabled: true),
        ]

        let result = RenamePipeline.apply(
            baseName: "18-04-2026_sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-18_sample")
    }

    func testNormalizeDatePrefixConvertsCompactFormat() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(kind: .normalizeDatePrefix, isEnabled: true),
        ]

        let result = RenamePipeline.apply(
            baseName: "20260418_sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-18_sample")
    }

    func testNormalizeDatePrefixLeavesUnsupportedTextUntouched() {
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(kind: .normalizeDatePrefix, isEnabled: true),
        ]

        let result = RenamePipeline.apply(
            baseName: "sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "sample")
    }

    func testRemoveCharactersBeforeDateStampKeepsInsertedDateIntact() throws {
        let manualDate = try XCTUnwrap(
            Calendar(identifier: .iso8601).date(from: DateComponents(year: 2026, month: 4, day: 18))
        )
        let file = FileItem(url: URL(fileURLWithPath: "/tmp/sample.txt"))
        let rules = [
            RenameRule(kind: .removeCharacters, isEnabled: true, removeCount: 2, removeDirection: .start),
            RenameRule(kind: .dateStamp, isEnabled: true, manualDate: manualDate, dateSource: .manual, datePosition: .prefix),
        ]

        let result = RenamePipeline.apply(
            baseName: "sample",
            rules: rules,
            context: RenameContext(itemIndex: 0, fileItem: file)
        )

        XCTAssertEqual(result, "2026-04-18_mple")
    }
}
