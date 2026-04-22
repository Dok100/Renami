import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class AppViewModel: ObservableObject {
    enum PreviewListMode: String, CaseIterable {
        case changedFirst
        case changedOnly

        var title: String {
            switch self {
            case .changedFirst:
                "Geändert zuerst"
            case .changedOnly:
                "Nur geändert"
            }
        }
    }

    @Published var files: [FileItem] = []
    @Published var rules: [RenameRule] = RenameRule.defaults()
    @Published var presets: [PresetStore.Preset] = PresetStore.load()
    @Published var selectedPresetID: PresetStore.Preset.ID?
    @Published var previewListMode: PreviewListMode = .changedFirst
    @Published private var renameFeedbackMessage: String?

    private var currentPreviews: [PreviewItem] {
        PreviewEngine.buildPreviews(items: files, rules: rules)
    }

    var selectedCount: Int {
        files.filter(\.isSelected).count
    }

    var previews: [PreviewItem] {
        currentPreviews
    }

    var displayedPreviews: [PreviewItem] {
        let filtered = switch previewListMode {
        case .changedFirst:
            currentPreviews
        case .changedOnly:
            currentPreviews.filter(\.isChanged)
        }

        return filtered.sorted { lhs, rhs in
            if lhs.isChanged != rhs.isChanged {
                return lhs.isChanged && !rhs.isChanged
            }

            return lhs.source.originalFilename.localizedCaseInsensitiveCompare(rhs.source.originalFilename) == .orderedAscending
        }
    }

    var changedCount: Int {
        currentPreviews.filter(\.isChanged).count
    }

    var errorCount: Int {
        currentPreviews.filter(\.hasErrors).count
    }

    var canRename: Bool {
        currentPreviews.contains { $0.isSelected && $0.isChanged } &&
            !currentPreviews.contains { $0.isSelected && $0.hasErrors }
    }

    var statusMessage: String {
        if let renameFeedbackMessage {
            return renameFeedbackMessage
        }

        if files.isEmpty {
            return "Noch keine Dateien geladen."
        } else if errorCount > 0 {
            return "\(errorCount) Konflikte blockieren das Umbenennen."
        } else if changedCount > 0 {
            return "Vorschau aktualisiert: \(changedCount) Namen geändert."
        } else {
            return "Keine Umbenennung aktiv."
        }
    }

    var allowedDropTypes: [UTType] {
        [.fileURL]
    }

    func importFiles() {
        renameFeedbackMessage = nil
        mergeImportedItems(FileImportService.pickFiles())
    }

    func importFolders() {
        renameFeedbackMessage = nil
        mergeImportedItems(FileImportService.pickFolders())
    }

    func handleDropped(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { [weak self] data, _ in
                guard let data,
                      let url = URL(dataRepresentation: data, relativeTo: nil)
                else {
                    return
                }

                Task { @MainActor in
                    self?.mergeImportedItems([url])
                }
            }
        }

        return !providers.isEmpty
    }

    func toggleSelection(for fileID: UUID) {
        renameFeedbackMessage = nil
        guard let index = files.firstIndex(where: { $0.id == fileID }) else {
            return
        }

        files[index].isSelected.toggle()
    }

    func removeFiles(at offsets: IndexSet) {
        renameFeedbackMessage = nil
        files.remove(atOffsets: offsets)
    }

    func clearFiles() {
        renameFeedbackMessage = nil
        files.removeAll()
    }

    func moveRuleUp(_ ruleID: UUID) {
        renameFeedbackMessage = nil
        guard let index = rules.firstIndex(where: { $0.id == ruleID }), index > 0 else {
            return
        }

        rules.swapAt(index, index - 1)
    }

    func moveRuleDown(_ ruleID: UUID) {
        renameFeedbackMessage = nil
        guard let index = rules.firstIndex(where: { $0.id == ruleID }), index < rules.count - 1 else {
            return
        }

        rules.swapAt(index, index + 1)
    }

    func requestRename() {
        renameFeedbackMessage = nil

        guard prepareDirectoryAccessForRename() else {
            return
        }

        let currentPreviews = previews

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = RenameExecutor.execute(previews: currentPreviews)

            DispatchQueue.main.async {
                self?.applyRenameResult(result, basedOn: currentPreviews)
            }
        }
    }

    func saveCurrentPreset(named name: String) {
        guard let outcome = PresetStore.upsertPreset(named: name, rules: rules, selectedPresetID: selectedPresetID) else {
            renameFeedbackMessage = "Preset-Name fehlt."
            return
        }

        presets = PresetStore.load()

        switch outcome {
        case let .created(preset):
            selectedPresetID = preset.id
            renameFeedbackMessage = "Preset „\(preset.name)“ gespeichert."
        case let .updated(preset):
            selectedPresetID = preset.id
            renameFeedbackMessage = "Preset „\(preset.name)“ aktualisiert."
        }
    }

    func applySelectedPreset() {
        renameFeedbackMessage = nil
        guard let selectedPresetID,
              let preset = presets.first(where: { $0.id == selectedPresetID })
        else {
            return
        }

        rules = preset.rules
        renameFeedbackMessage = "Preset „\(preset.name)“ geladen."
    }

    func deleteSelectedPreset() {
        guard let selectedPresetID,
              let preset = presets.first(where: { $0.id == selectedPresetID })
        else {
            renameFeedbackMessage = "Kein Preset ausgewählt."
            return
        }

        guard PresetStore.deletePreset(id: selectedPresetID) else {
            renameFeedbackMessage = "Preset konnte nicht gelöscht werden."
            return
        }

        presets = PresetStore.load()
        self.selectedPresetID = nil
        renameFeedbackMessage = "Preset „\(preset.name)“ gelöscht."
    }

    func exportSelectedPreset() {
        guard let selectedPresetID,
              let preset = presets.first(where: { $0.id == selectedPresetID })
        else {
            renameFeedbackMessage = "Kein Preset ausgewählt."
            return
        }

        do {
            let exportedURL = try PresetTransferService.exportPreset(preset)
            if exportedURL != nil {
                renameFeedbackMessage = "Preset „\(preset.name)“ exportiert."
            }
        } catch {
            renameFeedbackMessage = error.localizedDescription
        }
    }

    func importPreset() {
        do {
            guard let importedPreset = try PresetTransferService.importPreset() else {
                return
            }

            guard let outcome = PresetStore.upsertPreset(
                named: importedPreset.name,
                rules: importedPreset.rules,
                selectedPresetID: nil
            ) else {
                renameFeedbackMessage = "Preset-Datei ist ungültig."
                return
            }

            presets = PresetStore.load()

            switch outcome {
            case let .created(preset):
                selectedPresetID = preset.id
                renameFeedbackMessage = "Preset „\(preset.name)“ importiert."
            case let .updated(preset):
                selectedPresetID = preset.id
                renameFeedbackMessage = "Preset „\(preset.name)“ importiert und aktualisiert."
            }
        } catch {
            renameFeedbackMessage = error.localizedDescription
        }
    }

    func selectPreset(_ presetID: PresetStore.Preset.ID?) {
        selectedPresetID = presetID
    }

    func presetName(for presetID: PresetStore.Preset.ID?) -> String {
        guard let presetID,
              let preset = presets.first(where: { $0.id == presetID })
        else {
            return ""
        }

        return preset.name
    }

    func selectPreviewListMode(_ mode: PreviewListMode) {
        previewListMode = mode
    }

    func updateRule(_ updatedRule: RenameRule) {
        renameFeedbackMessage = nil
        guard let index = rules.firstIndex(where: { $0.id == updatedRule.id }) else {
            return
        }

        rules[index] = updatedRule
    }

    private func mergeImportedItems(_ urls: [URL]) {
        let importedItems = FileImportService.buildFileItems(from: urls)
        let existingURLs = Set(files.map(\.url.standardizedFileURL))
        let newItems = importedItems.filter { !existingURLs.contains($0.url.standardizedFileURL) }
        files.append(contentsOf: newItems)
    }

    private func prepareDirectoryAccessForRename() -> Bool {
        let affectedFiles = files.filter { file in
            file.isSelected && file.needsDirectoryAccessGrant
        }

        guard !affectedFiles.isEmpty else {
            return true
        }

        let requiredDirectories = Array(Set(affectedFiles.map(\.directoryURL.standardizedFileURL)))
            .sorted { $0.path(percentEncoded: false) < $1.path(percentEncoded: false) }
        let grantedDirectories = Set(
            FileImportService.pickAccessFolders(for: requiredDirectories)
                .map(\.standardizedFileURL)
        )

        guard !grantedDirectories.isEmpty else {
            renameFeedbackMessage = "Um einzelne Dateien umzubenennen, bitte den Zielordner freigeben."
            return false
        }

        let missingDirectories = requiredDirectories.filter { !grantedDirectories.contains($0) }
        guard missingDirectories.isEmpty else {
            renameFeedbackMessage = "Nicht alle Zielordner wurden freigegeben. Bitte die betroffenen Ordner erneut auswählen."
            return false
        }

        files = files.map { file in
            guard let grantedDirectory = grantedDirectories.first(where: { $0 == file.directoryURL.standardizedFileURL }) else {
                return file
            }

            var updated = file
            updated.accessURL = grantedDirectory
            return updated
        }

        return true
    }

    private func applyRenameResult(_ result: RenameExecutionResult, basedOn previews: [PreviewItem]) {
        if result.failures.isEmpty {
            files = previews.map { preview in
                let nextURL = result.succeededIDs.contains(preview.id) ? preview.targetURL : preview.source.url
                return FileItem(
                    id: preview.source.id,
                    url: nextURL,
                    accessURL: preview.source.accessURL,
                    isSelected: preview.source.isSelected
                )
            }
            renameFeedbackMessage = result.succeededIDs.isEmpty
                ? "Keine Dateien mussten umbenannt werden."
                : "\(result.succeededIDs.count) Dateien erfolgreich umbenannt."
            return
        }

        let firstFailure = result.failures.values.sorted().first ?? "Unbekannter Fehler"
        renameFeedbackMessage = "\(result.failures.count) Dateien konnten nicht umbenannt werden. \(firstFailure)"
    }
}
