@testable import Renami
import XCTest

final class PresetTransferServiceTests: XCTestCase {
    func testWriteAndReadPresetRoundTrip() throws {
        let preset = PresetStore.Preset(
            id: UUID(),
            name: "Fotos",
            rules: [RenameRule(kind: .prefix, isEnabled: true, textValue: "2026-")]
        )
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")

        try PresetTransferService.writePreset(preset, to: fileURL)
        let loaded = try PresetTransferService.readPreset(from: fileURL)

        XCTAssertEqual(loaded.name, preset.name)
        XCTAssertEqual(loaded.rules, preset.rules)

        try? FileManager.default.removeItem(at: fileURL)
    }

    func testReadPresetRejectsEmptyName() throws {
        let preset = PresetStore.Preset(
            id: UUID(),
            name: "   ",
            rules: [RenameRule(kind: .suffix, isEnabled: true, textValue: "_x")]
        )
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")

        try PresetTransferService.writePreset(preset, to: fileURL)

        XCTAssertThrowsError(try PresetTransferService.readPreset(from: fileURL))

        try? FileManager.default.removeItem(at: fileURL)
    }
}
