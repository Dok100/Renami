import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class AppViewModel: ObservableObject {
    enum PreviewListMode: String, CaseIterable {
        case all
        case changedOnly
        case conflictsOnly

        var title: String {
            switch self {
            case .all:
                "Alle"
            case .changedOnly:
                "Nur geändert"
            case .conflictsOnly:
                "Nur Konflikte"
            }
        }
    }

    @Published var files: [FileItem] = []
    @Published var rules: [RenameRule] = RenameRule.defaults()
    @Published var presets: [PresetStore.Preset] = PresetStore.load()
    @Published var selectedPresetID: PresetStore.Preset.ID?
    @Published var previewListMode: PreviewListMode = .all
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
        case .all:
            currentPreviews
        case .changedOnly:
            currentPreviews.filter(\.isChanged)
        case .conflictsOnly:
            currentPreviews.filter(\.hasErrors)
        }

        return filtered.sorted { lhs, rhs in
            let rank: (PreviewItem) -> Int = { preview in
                switch preview.status {
                case .conflict: 0
                case .changed: 1
                case .unchanged: 2
                }
            }

            if rank(lhs) != rank(rhs) {
                return rank(lhs) < rank(rhs)
            }

            return lhs.source.originalFilename.localizedCaseInsensitiveCompare(rhs.source.originalFilename) == .orderedAscending
        }
    }

    var changedCount: Int {
        currentPreviews.count(where: \.isChanged)
    }

    var errorCount: Int {
        currentPreviews.count(where: \.hasErrors)
    }

    var unchangedCount: Int {
        currentPreviews.count { !$0.isChanged }
    }

    var activeRuleCount: Int {
        rules.count(where: \.isEnabled)
    }

    var renameCandidateCount: Int {
        currentPreviews.count { $0.isSelected && $0.isChanged && !$0.hasErrors }
    }

    var selectedConflictCount: Int {
        currentPreviews.count { $0.isSelected && $0.hasErrors }
    }

    var selectionSummary: String {
        if files.isEmpty {
            return "Noch keine Quellen geladen"
        }

        if selectedCount == 0 {
            return "Keine Datei ausgewählt"
        }

        return "\(selectedCount) von \(files.count) Dateien ausgewählt"
    }

    var rulesSummary: String {
        if activeRuleCount == 0 {
            return "Noch keine Regel aktiv"
        }

        return "\(activeRuleCount) Regeln aktiv"
    }

    var previewSummary: String {
        if files.isEmpty {
            return "Importiere zuerst Dateien oder Ordner."
        }

        if activeRuleCount == 0 {
            return "Aktiviere mindestens eine Regel, damit die Vorschau einen Unterschied zeigen kann."
        }

        if currentPreviews.isEmpty {
            return "Noch keine Vorschau verfügbar."
        }

        if errorCount > 0 {
            return "\(errorCount) Konflikte müssen vor dem Umbenennen behoben werden."
        }

        if renameCandidateCount == 0 {
            return "Aktuell gibt es keine ausgewählten Dateien mit Änderungen."
        }

        return "\(renameCandidateCount) Dateien können sicher umbenannt werden."
    }

    var renameButtonTitle: String {
        renameCandidateCount > 0 ? "\(renameCandidateCount) Dateien umbenennen" : "Umbenennen"
    }

    var renameHelpText: String {
        if files.isEmpty {
            return "Der Ablauf startet mit Quellen auf der linken Seite."
        }

        if activeRuleCount == 0 {
            return "Definiere zuerst Regeln, bevor du die Umbenennung ausführst."
        }

        if selectedConflictCount > 0 {
            return "Konflikte blockieren die Aktion, bis alle ausgewählten Dateien gültig sind."
        }

        if renameCandidateCount == 0 {
            return "Es gibt derzeit keine ausgewählten Dateien mit einer tatsächlichen Änderung."
        }

        return "Nur ausgewählte, gültige und tatsächlich geänderte Dateien werden umbenannt."
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

    var hasPreviewContent: Bool {
        !currentPreviews.isEmpty
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

    func moveRule(_ ruleID: UUID, before targetRuleID: UUID) {
        renameFeedbackMessage = nil
        guard ruleID != targetRuleID,
              let sourceIndex = rules.firstIndex(where: { $0.id == ruleID }),
              let targetIndex = rules.firstIndex(where: { $0.id == targetRuleID })
        else {
            return
        }

        let movedRule = rules.remove(at: sourceIndex)
        let adjustedTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        rules.insert(movedRule, at: adjustedTargetIndex)
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
