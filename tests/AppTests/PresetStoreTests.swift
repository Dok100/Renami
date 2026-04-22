@testable import Renami
import XCTest

final class PresetStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "PresetStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testUpsertCreatesNewPreset() throws {
        let rules = [RenameRule(kind: .prefix, isEnabled: true, textValue: "A_")]

        let outcome = try XCTUnwrap(PresetStore.upsertPreset(
            named: "Standard",
            rules: rules,
            selectedPresetID: nil,
            userDefaults: defaults
        ))

        guard case let .created(preset) = outcome else {
            return XCTFail("Expected created preset")
        }

        XCTAssertEqual(preset.name, "Standard")
        XCTAssertEqual(PresetStore.load(userDefaults: defaults).count, 1)
    }

    func testUpsertUpdatesExistingPresetByNormalizedName() throws {
        _ = PresetStore.upsertPreset(
            named: "Ablage",
            rules: [RenameRule(kind: .prefix, isEnabled: true, textValue: "Alt_")],
            selectedPresetID: nil,
            userDefaults: defaults
        )

        let outcome = try XCTUnwrap(PresetStore.upsertPreset(
            named: " ablage ",
            rules: [RenameRule(kind: .suffix, isEnabled: true, textValue: "_neu")],
            selectedPresetID: nil,
            userDefaults: defaults
        ))

        guard case let .updated(preset) = outcome else {
            return XCTFail("Expected updated preset")
        }

        XCTAssertEqual(PresetStore.load(userDefaults: defaults).count, 1)
        XCTAssertEqual(preset.name, "ablage")
        XCTAssertEqual(preset.rules.first?.kind, .suffix)
    }

    func testDeleteRemovesPreset() throws {
        let created = try XCTUnwrap(PresetStore.upsertPreset(
            named: "Export",
            rules: [RenameRule(kind: .numbering, isEnabled: true)],
            selectedPresetID: nil,
            userDefaults: defaults
        ))

        let presetID = switch created {
        case let .created(preset), let .updated(preset):
            preset.id
        }

        XCTAssertTrue(PresetStore.deletePreset(id: presetID, userDefaults: defaults))
        XCTAssertTrue(PresetStore.load(userDefaults: defaults).isEmpty)
    }
}
