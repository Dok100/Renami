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
}
