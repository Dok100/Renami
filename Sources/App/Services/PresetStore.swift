import Foundation

enum PresetStore {
    private static let key = "renami.presets"

    struct Preset: Identifiable, Codable, Hashable {
        let id: UUID
        var name: String
        var rules: [RenameRule]
    }

    static func load() -> [Preset] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let presets = try? JSONDecoder().decode([Preset].self, from: data)
        else {
            return []
        }

        return presets
    }

    static func save(_ presets: [Preset]) {
        guard let data = try? JSONEncoder().encode(presets) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}
