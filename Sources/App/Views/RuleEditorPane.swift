import SwiftUI

struct RuleEditorPane: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var presetName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Regeln")
                    .font(.headline)
                Spacer()
                Picker("Preset", selection: selectedPresetBinding) {
                    Text("Kein Preset").tag(PresetStore.Preset.ID?.none)
                    ForEach(viewModel.presets) { preset in
                        Text(preset.name).tag(Optional(preset.id))
                    }
                }
                .frame(width: 180)

                Button("Laden") {
                    viewModel.applySelectedPreset()
                }
                .disabled(viewModel.selectedPresetID == nil)
            }

            HStack(spacing: 8) {
                TextField("Aktuelle Regeln als Preset speichern", text: $presetName)
                Button("Speichern") {
                    let nameToSave = presetName
                    DispatchQueue.main.async {
                        viewModel.saveCurrentPreset(named: nameToSave)
                        presetName = ""
                    }
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(viewModel.rules.enumerated()), id: \.element.id) { index, rule in
                        RuleCard(
                            rule: binding(for: rule.id),
                            onMoveUp: { viewModel.moveRuleUp(rule.id) },
                            onMoveDown: { viewModel.moveRuleDown(rule.id) },
                            canMoveUp: index > 0,
                            canMoveDown: index < viewModel.rules.count - 1
                        )
                    }
                }
            }
        }
        .padding(20)
        .frame(minWidth: 360, idealWidth: 420, maxWidth: 460, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func binding(for ruleID: UUID) -> Binding<RenameRule> {
        Binding(
            get: {
                viewModel.rules.first(where: { $0.id == ruleID }) ?? RenameRule(kind: .prefix)
            },
            set: { updated in
                DispatchQueue.main.async {
                    viewModel.updateRule(updated)
                }
            }
        )
    }

    private var selectedPresetBinding: Binding<PresetStore.Preset.ID?> {
        Binding(
            get: { viewModel.selectedPresetID },
            set: { selectedID in
                DispatchQueue.main.async {
                    viewModel.selectPreset(selectedID)
                }
            }
        )
    }
}

private struct RuleCard: View {
    @Binding var rule: RenameRule
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.title)
                        .font(.headline)
                    Text(rule.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Aktiv", isOn: enabledBinding)
                    .toggleStyle(.switch)
                    .labelsHidden()
                VStack(spacing: 6) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!canMoveUp)
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!canMoveDown)
                }
                .buttonStyle(.borderless)
            }

            controls
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    @ViewBuilder
    private var controls: some View {
        switch rule.kind {
        case .findReplace:
            LabeledContent("Suchen") {
                TextField("Text suchen", text: binding(\.textValue))
            }
            LabeledContent("Ersetzen durch") {
                TextField("Neuer Text", text: binding(\.secondaryTextValue))
            }

        case .prefix:
            LabeledContent("Präfix") {
                TextField("z. B. Projekt_", text: binding(\.textValue))
            }

        case .suffix:
            LabeledContent("Suffix") {
                TextField("z. B. _final", text: binding(\.textValue))
            }

        case .insertText:
            LabeledContent("Text") {
                TextField("Einzufügender Text", text: binding(\.textValue))
            }
            Picker("Position", selection: binding(\.insertPosition)) {
                ForEach(RenameRule.InsertPosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            if rule.insertPosition == .index {
                Stepper("Index: \(rule.insertIndex)", value: binding(\.insertIndex), in: 0 ... 200)
            }

        case .dateStamp:
            Picker("Quelle", selection: binding(\.dateSource)) {
                ForEach(RenameRule.DateSource.allCases, id: \.self) { source in
                    Text(source.title).tag(source)
                }
            }

            if rule.dateSource == .manual {
                DatePicker(
                    "Datum",
                    selection: binding(\.manualDate),
                    displayedComponents: [.date]
                )
                Text("Ausgabeformat: 2026-04-18_")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Ausgabeformat: 2026-04-18_")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker("Position", selection: binding(\.datePosition)) {
                ForEach(RenameRule.DatePosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            Toggle(
                "Nur einfügen, wenn noch kein Datums-Präfix wie 2026-04-18_ vorhanden ist",
                isOn: binding(\.onlyIfNoDatePrefixExists)
            )

        case .normalizeDatePrefix:
            Text("Erkennt vorhandene Datums-Präfixe am Anfang und vereinheitlicht sie auf 2026-04-18_.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Unterstützte Formate: 2026-04-18_, 18-04-2026_, 2026_04_18_, 20260418_")
                .font(.caption)
                .foregroundStyle(.secondary)

        case .numbering:
            Picker("Position", selection: binding(\.numberPosition)) {
                ForEach(RenameRule.NumberPosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            Stepper("Startwert: \(rule.numberStart)", value: binding(\.numberStart), in: 0 ... 9999)
            Stepper("Schrittweite: \(rule.numberStep)", value: binding(\.numberStep), in: 1 ... 999)
            Stepper("Stellen: \(rule.numberPadding)", value: binding(\.numberPadding), in: 1 ... 8)

            LabeledContent("Trenner") {
                TextField("z. B. _", text: binding(\.separator))
            }

        case .removeCharacters:
            Picker("Richtung", selection: binding(\.removeDirection)) {
                ForEach(RenameRule.RemoveDirection.allCases, id: \.self) { direction in
                    Text(direction.title).tag(direction)
                }
            }
            .pickerStyle(.segmented)

            Stepper("Zeichen: \(rule.removeCount)", value: binding(\.removeCount), in: 0 ... 100)

        case .caseTransform:
            Picker("Schreibweise", selection: binding(\.caseStyle)) {
                ForEach(RenameRule.CaseStyle.allCases, id: \.self) { style in
                    Text(style.title).tag(style)
                }
            }

        case .windowsSanitize:
            Toggle("Reservierte Windows-Zeichen ersetzen", isOn: binding(\.replaceReservedCharacters))
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { rule.isEnabled },
            set: { rule.isEnabled = $0 }
        )
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<RenameRule, Value>) -> Binding<Value> {
        Binding(
            get: { rule[keyPath: keyPath] },
            set: { value in
                rule[keyPath: keyPath] = value
            }
        )
    }
}
