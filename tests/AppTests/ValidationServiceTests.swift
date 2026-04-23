@testable import Renami
import XCTest

final class ValidationServiceTests: XCTestCase {
    func testValidationMarksDuplicateTargets() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let first = FileItem(url: directory.appendingPathComponent("a.txt"))
        let second = FileItem(url: directory.appendingPathComponent("b.txt"))

        let previews = [
            PreviewItem(
                id: first.id,
                source: first,
                proposedBaseName: "same",
                targetFilename: "same.txt",
                targetURL: directory.appendingPathComponent("same.txt"),
                validationIssues: []
            ),
            PreviewItem(
                id: second.id,
                source: second,
                proposedBaseName: "same",
                targetFilename: "same.txt",
                targetURL: directory.appendingPathComponent("same.txt"),
                validationIssues: []
            ),
        ]

        let validated = ValidationService.applyValidation(to: previews)

        XCTAssertTrue(validated.allSatisfy(\.hasErrors))
    }

    func testValidationRejectsEmptyBaseName() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let file = FileItem(url: directory.appendingPathComponent("source.txt"))

        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: "",
            targetFilename: ".txt",
            targetURL: directory.appendingPathComponent(".txt"),
            validationIssues: []
        )

        let validated = ValidationService.applyValidation(to: [preview])

        XCTAssertEqual(validated.first?.validationIssues.first?.kind, .emptyName)
    }

    func testValidationDoesNotFlagCaseOnlyRenameOfSameFileAsExistingTargetCollision() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let sourceURL = directory.appendingPathComponent("bericht.txt")
        try "inhalt".write(to: sourceURL, atomically: true, encoding: .utf8)

        let file = FileItem(url: sourceURL)
        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: "Bericht",
            targetFilename: "Bericht.txt",
            targetURL: directory.appendingPathComponent("Bericht.txt"),
            validationIssues: []
        )

        let validated = try XCTUnwrap(ValidationService.applyValidation(to: [preview]).first)

        XCTAssertFalse(validated.validationIssues.contains(where: { $0.kind == .existingTargetCollision }))
    }

    func testValidationAllowsColonInFilename() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let file = FileItem(url: directory.appendingPathComponent("quelle.txt"))

        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: #"Lieferkettengesetz: Das drängt Kinder"#,
            targetFilename: #"Lieferkettengesetz: Das drängt Kinder.txt"#,
            targetURL: directory.appendingPathComponent(#"Lieferkettengesetz: Das drängt Kinder.txt"#),
            validationIssues: []
        )

        let validated = ValidationService.applyValidation(to: [preview])

        XCTAssertFalse(validated.first?.validationIssues.contains(where: { $0.kind == .invalidCharacter }) ?? true)
    }

    func testValidationRejectsSlashWithSpecificMessage() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let file = FileItem(url: directory.appendingPathComponent("quelle.txt"))

        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: "Ordner/Datei",
            targetFilename: "Ordner/Datei.txt",
            targetURL: directory.appendingPathComponent("Ordner/Datei.txt"),
            validationIssues: []
        )

        let validated = ValidationService.applyValidation(to: [preview])

        XCTAssertEqual(validated.first?.validationIssues.first(where: { $0.kind == .invalidCharacter })?.message, "Schrägstrich / ist im Dateinamen nicht erlaubt")
    }

    func testValidationRejectsTargetURLSplitByPathSeparator() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let file = FileItem(url: directory.appendingPathComponent("quelle.txt"))

        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: "Ordner/Datei",
            targetFilename: "Ordner/Datei.txt",
            targetURL: directory.appendingPathComponent("Ordner/Datei.txt"),
            validationIssues: []
        )

        let validated = ValidationService.applyValidation(to: [preview])

        XCTAssertTrue(validated.first?.hasErrors ?? false)
    }

    func testValidationRejectsLineBreaksInFilename() {
        let directory = URL(fileURLWithPath: "/tmp/renami-tests", isDirectory: true)
        let file = FileItem(url: directory.appendingPathComponent("quelle.txt"))

        let preview = PreviewItem(
            id: file.id,
            source: file,
            proposedBaseName: "Erste Zeile\nZweite Zeile",
            targetFilename: "Erste Zeile\nZweite Zeile.txt",
            targetURL: directory.appendingPathComponent("Erste Zeile\nZweite Zeile.txt"),
            validationIssues: []
        )

        let validated = ValidationService.applyValidation(to: [preview])

        XCTAssertEqual(validated.first?.validationIssues.first(where: { $0.kind == .invalidCharacter })?.message, "Zeilenumbrüche sind im Dateinamen nicht erlaubt")
    }
}
