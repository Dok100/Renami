import AppKit
import Foundation
import UniformTypeIdentifiers

enum PresetTransferService {
    struct PresetDocument: Codable {
        let version: Int
        let preset: PresetStore.Preset
    }

    enum TransferError: LocalizedError {
        case invalidFile

        var errorDescription: String? {
            switch self {
            case .invalidFile:
                "Die Preset-Datei ist ungültig."
            }
        }
    }

    static func exportPreset(_ preset: PresetStore.Preset) throws -> URL? {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.allowedContentTypes = [.json]
        panel.prompt = "Exportieren"
        panel.nameFieldStringValue = suggestedFilename(for: preset.name)

        guard panel.runModal() == .OK, let destinationURL = panel.url else {
            return nil
        }

        try writePreset(preset, to: destinationURL)
        return destinationURL
    }

    static func importPreset() throws -> PresetStore.Preset? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        panel.prompt = "Importieren"

        guard panel.runModal() == .OK, let sourceURL = panel.url else {
            return nil
        }

        return try readPreset(from: sourceURL)
    }

    static func writePreset(_ preset: PresetStore.Preset, to url: URL) throws {
        let document = PresetDocument(version: 1, preset: preset)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(document)
        try data.write(to: url, options: .atomic)
    }

    static func readPreset(from url: URL) throws -> PresetStore.Preset {
        let data = try Data(contentsOf: url)
        let document = try JSONDecoder().decode(PresetDocument.self, from: data)

        guard !document.preset.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TransferError.invalidFile
        }

        return document.preset
    }

    private static func suggestedFilename(for presetName: String) -> String {
        let sanitizedName = presetName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")

        let fallback = sanitizedName.isEmpty ? "renami-preset" : sanitizedName
        return "\(fallback).json"
    }
}
