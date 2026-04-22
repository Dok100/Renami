import Foundation

enum PresetStore {
    private static let key = "renami.presets"

    enum SaveOutcome {
        case created(Preset)
        case updated(Preset)
    }

    struct Preset: Identifiable, Codable, Hashable {
        let id: UUID
        var name: String
        var rules: [RenameRule]
    }

    static func load(userDefaults: UserDefaults = .standard) -> [Preset] {
        guard let data = userDefaults.data(forKey: key),
              let presets = try? JSONDecoder().decode([Preset].self, from: data)
        else {
            return []
        }

        return presets
    }

    static func save(_ presets: [Preset], userDefaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(presets) else {
            return
        }

        userDefaults.set(data, forKey: key)
    }

    static func upsertPreset(
        named name: String,
        rules: [RenameRule],
        selectedPresetID: Preset.ID?,
        userDefaults: UserDefaults = .standard
    ) -> SaveOutcome? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        var presets = load(userDefaults: userDefaults)
        let normalizedName = normalizedPresetName(trimmed)

        if let selectedPresetID,
           let selectedIndex = presets.firstIndex(where: { $0.id == selectedPresetID })
        {
            presets[selectedIndex].name = trimmed
            presets[selectedIndex].rules = rules
            let updated = presets[selectedIndex]
            save(presets, userDefaults: userDefaults)
            return .updated(updated)
        }

        if let existingIndex = presets.firstIndex(where: { normalizedPresetName($0.name) == normalizedName }) {
            presets[existingIndex].name = trimmed
            presets[existingIndex].rules = rules
            let updated = presets[existingIndex]
            save(presets, userDefaults: userDefaults)
            return .updated(updated)
        }

        let created = Preset(id: UUID(), name: trimmed, rules: rules)
        presets.append(created)
        presets.sort { normalizedPresetName($0.name) < normalizedPresetName($1.name) }
        save(presets, userDefaults: userDefaults)
        return .created(created)
    }

    static func deletePreset(id: Preset.ID, userDefaults: UserDefaults = .standard) -> Bool {
        var presets = load(userDefaults: userDefaults)
        let originalCount = presets.count
        presets.removeAll { $0.id == id }
        guard presets.count != originalCount else {
            return false
        }

        save(presets, userDefaults: userDefaults)
        return true
    }

    private static func normalizedPresetName(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
