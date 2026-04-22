import SwiftUI
import UniformTypeIdentifiers

struct RuleEditorPane: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var presetName = ""
    @State private var expandedRuleIDs = Set<UUID>()
    @State private var draggedRuleID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            presetPanel

            if viewModel.activeRuleCount == 0 {
                onboardingHint
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(orderedRuleGroups) { group in
                        RuleSectionBlock(
                            section: group.section,
                            rules: group.rules,
                            bindingForRuleID: binding(for:),
                            expandedRuleIDs: $expandedRuleIDs,
                            draggedRuleID: $draggedRuleID,
                            moveRuleUp: viewModel.moveRuleUp,
                            moveRuleDown: viewModel.moveRuleDown,
                            moveRuleBefore: viewModel.moveRule,
                            allRules: viewModel.rules
                        )
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(18)
        .frame(minWidth: 380, idealWidth: 430, maxWidth: 470, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            presetName = viewModel.presetName(for: viewModel.selectedPresetID)
            syncExpandedRules()
        }
        .onChange(of: viewModel.selectedPresetID) { selectedPresetID in
            presetName = viewModel.presetName(for: selectedPresetID)
        }
        .onChange(of: viewModel.rules) { _ in
            syncExpandedRules()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("2")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.accentColor.opacity(0.12)))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Regeln")
                        .font(.title3.weight(.semibold))
                    Text("Die Reihenfolge wirkt von oben nach unten. Starte mit den wenigen Regeln, die den Zielnamen wirklich formen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            RuleActivitySummary(activeCount: viewModel.activeRuleCount)
        }
    }

    private var presetPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Presets")
                        .font(.headline)
                }

                Spacer()

                Picker("Preset", selection: selectedPresetBinding) {
                    Text("Kein Preset").tag(PresetStore.Preset.ID?.none)
                    ForEach(viewModel.presets) { preset in
                        Text(preset.name).tag(Optional(preset.id))
                    }
                }
                .labelsHidden()
                .frame(width: 200)
            }

            HStack(spacing: 8) {
                TextField("Regelset benennen", text: $presetName)

                Button(saveButtonTitle) {
                    let nameToSave = presetName
                    DispatchQueue.main.async {
                        viewModel.saveCurrentPreset(named: nameToSave)
                        presetName = viewModel.presetName(for: viewModel.selectedPresetID)
                    }
                }
                .disabled(trimmedPresetName.isEmpty)
            }

            HStack(spacing: 8) {
                Button("Laden") {
                    viewModel.applySelectedPreset()
                }
                .disabled(viewModel.selectedPresetID == nil)

                Button("Importieren") {
                    viewModel.importPreset()
                }

                Button("Exportieren") {
                    viewModel.exportSelectedPreset()
                }
                .disabled(viewModel.selectedPresetID == nil)

                Spacer()

                Button("Löschen", role: .destructive) {
                    viewModel.deleteSelectedPreset()
                    presetName = ""
                }
                .disabled(viewModel.selectedPresetID == nil)
            }
            .buttonStyle(.bordered)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var onboardingHint: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Schneller Einstieg")
                .font(.headline)

            Text("Für die meisten Fälle reichen ein bis zwei Regeln. Starte mit einer dieser häufigen Optionen:")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                suggestionButton(for: .findReplace, label: "Text ersetzen")
                suggestionButton(for: .prefix, label: "Präfix")
                suggestionButton(for: .dateStamp, label: "Datum")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.accentColor.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.12), lineWidth: 1)
        )
    }

    private func suggestionButton(for kind: RenameRule.Kind, label: String) -> some View {
        Button(label) {
            guard let rule = viewModel.rules.first(where: { $0.kind == kind }) else {
                return
            }

            var updatedRule = rule
            updatedRule.isEnabled = true
            viewModel.updateRule(updatedRule)
            expandedRuleIDs.insert(rule.id)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    private func binding(for ruleID: UUID) -> Binding<RenameRule> {
        Binding(
            get: {
                viewModel.rules.first(where: { $0.id == ruleID }) ?? RenameRule(kind: .prefix)
            },
            set: { updated in
                DispatchQueue.main.async {
                    viewModel.updateRule(updated)
                    if updated.isEnabled {
                        expandedRuleIDs.insert(updated.id)
                    }
                }
            }
        )
    }

    private var orderedRuleGroups: [OrderedRuleGroup] {
        var groups: [OrderedRuleGroup] = []

        for rule in viewModel.rules {
            let section = RuleSection.section(for: rule.kind)
            if let lastIndex = groups.indices.last, groups[lastIndex].section == section {
                groups[lastIndex].rules.append(rule)
            } else {
                groups.append(OrderedRuleGroup(section: section, rules: [rule]))
            }
        }

        return groups
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

    private var trimmedPresetName: String {
        presetName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var saveButtonTitle: String {
        viewModel.selectedPresetID == nil ? "Speichern" : "Aktualisieren"
    }

    private func syncExpandedRules() {
        let enabledIDs = viewModel.rules.filter(\.isEnabled).map(\.id)
        expandedRuleIDs.formUnion(enabledIDs)
    }
}

private struct OrderedRuleGroup: Identifiable {
    let id = UUID()
    let section: RuleSection
    var rules: [RenameRule]
}

private enum RuleSection {
    case text
    case naming
    case date
    case cleanup

    static func section(for kind: RenameRule.Kind) -> RuleSection {
        switch kind {
        case .findReplace, .insertText:
            .text
        case .prefix, .suffix, .numbering:
            .naming
        case .dateStamp, .normalizeDatePrefix:
            .date
        case .removeCharacters, .caseTransform, .windowsSanitize:
            .cleanup
        }
    }

    var title: String {
        switch self {
        case .text:
            "Textoperationen"
        case .naming:
            "Struktur und Reihenfolge"
        case .date:
            "Datum und Einordnung"
        case .cleanup:
            "Bereinigung"
        }
    }
}

private struct RuleSectionBlock: View {
    let section: RuleSection
    let rules: [RenameRule]
    let bindingForRuleID: (UUID) -> Binding<RenameRule>
    @Binding var expandedRuleIDs: Set<UUID>
    @Binding var draggedRuleID: UUID?
    let moveRuleUp: (UUID) -> Void
    let moveRuleDown: (UUID) -> Void
    let moveRuleBefore: (UUID, UUID) -> Void
    let allRules: [RenameRule]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.title)
                    .font(.headline)

                Spacer()

                Text("\(rules.count(where: \.isEnabled)) aktiv")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(rules) { rule in
                    RuleCard(
                        rule: bindingForRuleID(rule.id),
                        isExpanded: Binding(
                            get: { expandedRuleIDs.contains(rule.id) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedRuleIDs.insert(rule.id)
                                } else {
                                    expandedRuleIDs.remove(rule.id)
                                }
                            }
                        ),
                        isDragged: draggedRuleID == rule.id,
                        onStartDrag: { draggedRuleID = rule.id },
                        onMoveUp: { moveRuleUp(rule.id) },
                        onMoveDown: { moveRuleDown(rule.id) },
                        canMoveUp: canMoveUp(rule.id),
                        canMoveDown: canMoveDown(rule.id)
                    )
                    .onDrop(
                        of: [UTType.text],
                        delegate: RuleDropDelegate(
                            targetRuleID: rule.id,
                            draggedRuleID: $draggedRuleID,
                            moveRuleBefore: moveRuleBefore
                        )
                    )
                }
            }
        }
    }

    private func canMoveUp(_ ruleID: UUID) -> Bool {
        guard let index = allRules.firstIndex(where: { $0.id == ruleID }) else { return false }
        return index > 0
    }

    private func canMoveDown(_ ruleID: UUID) -> Bool {
        guard let index = allRules.firstIndex(where: { $0.id == ruleID }) else { return false }
        return index < allRules.count - 1
    }
}

private struct RuleCard: View {
    @Binding var rule: RenameRule
    @Binding var isExpanded: Bool
    let isDragged: Bool
    let onStartDrag: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                if !rule.isEnabled {
                    Text("Noch inaktiv. Aktivieren, wenn diese Regel wirklich Teil des finalen Namens sein soll.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                controls
            }
            .padding(.top, 12)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 3) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 9, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(.secondary.opacity(0.8))
                }
                .frame(width: 18)
                .help("Zum Umordnen ziehen oder die Pfeile im Menü nutzen")
                .onDrag {
                    onStartDrag()
                    return NSItemProvider(object: rule.id.uuidString as NSString)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(rule.title)
                            .font(.headline.weight(rule.isEnabled ? .semibold : .medium))

                        Text(rule.isEnabled ? "Aktiv" : "Inaktiv")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(rule.isEnabled ? Color.accentColor : Color.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill((rule.isEnabled ? Color.accentColor : Color.secondary).opacity(0.12)))
                    }

                    if isExpanded || rule.isEnabled {
                        Text(rule.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Toggle("Aktiv", isOn: Binding(
                    get: { rule.isEnabled },
                    set: { newValue in
                        rule.isEnabled = newValue
                        if newValue {
                            isExpanded = true
                        }
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()

                Menu {
                    Button("Nach oben", action: onMoveUp)
                        .disabled(!canMoveUp)
                    Button("Nach unten", action: onMoveDown)
                        .disabled(!canMoveDown)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(cardBorder, lineWidth: 1)
        )
        .opacity(isDragged ? 0.72 : 1)
    }

    private var cardBackground: Color {
        if isDragged {
            return Color.accentColor.opacity(0.12)
        }

        return rule.isEnabled ? Color.accentColor.opacity(0.06) : Color(nsColor: .controlBackgroundColor)
    }

    private var cardBorder: Color {
        if isDragged {
            return Color.accentColor.opacity(0.35)
        }

        return rule.isEnabled ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08)
    }

    @ViewBuilder
    private var controls: some View {
        switch rule.kind {
        case .findReplace:
            LabeledContent("Suchen") {
                TextField("Zu ersetzenden Text eingeben", text: $rule.textValue)
            }
            LabeledContent("Ersetzen durch") {
                TextField("Neuen Text eingeben", text: $rule.secondaryTextValue)
            }

        case .prefix:
            LabeledContent("Präfix") {
                TextField("z. B. Projekt_", text: $rule.textValue)
            }

        case .suffix:
            LabeledContent("Suffix") {
                TextField("z. B. _final", text: $rule.textValue)
            }

        case .insertText:
            LabeledContent("Text") {
                TextField("Zusätzlichen Text eingeben", text: $rule.textValue)
            }

            Picker("Position", selection: $rule.insertPosition) {
                ForEach(RenameRule.InsertPosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            if rule.insertPosition == .index {
                Stepper("Einfügeposition: \(rule.insertIndex)", value: $rule.insertIndex, in: 0 ... 200)
            }

        case .dateStamp:
            Picker("Quelle", selection: $rule.dateSource) {
                ForEach(RenameRule.DateSource.allCases, id: \.self) { source in
                    Text(source.title).tag(source)
                }
            }

            if rule.dateSource == .manual {
                DatePicker("Datum", selection: $rule.manualDate, displayedComponents: [.date])
            }

            Text("Format in der Vorschau: 2026-04-18_")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Position", selection: $rule.datePosition) {
                ForEach(RenameRule.DatePosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Nur ergänzen, wenn noch kein Datums-Präfix vorhanden ist", isOn: $rule.onlyIfNoDatePrefixExists)

        case .normalizeDatePrefix:
            Text("Erkennt Präfixe wie 18-04-2026_, 2026_04_18_ oder 20260418_ und vereinheitlicht sie auf 2026-04-18_.")
                .font(.caption)
                .foregroundStyle(.secondary)

        case .numbering:
            Picker("Position", selection: $rule.numberPosition) {
                ForEach(RenameRule.NumberPosition.allCases, id: \.self) { position in
                    Text(position.title).tag(position)
                }
            }
            .pickerStyle(.segmented)

            Stepper("Startwert: \(rule.numberStart)", value: $rule.numberStart, in: 0 ... 9999)
            Stepper("Schrittweite: \(rule.numberStep)", value: $rule.numberStep, in: 1 ... 999)
            Stepper("Stellen: \(rule.numberPadding)", value: $rule.numberPadding, in: 1 ... 8)

            LabeledContent("Trennzeichen") {
                TextField("z. B. _", text: $rule.separator)
            }

        case .removeCharacters:
            Picker("Richtung", selection: $rule.removeDirection) {
                ForEach(RenameRule.RemoveDirection.allCases, id: \.self) { direction in
                    Text(direction.title).tag(direction)
                }
            }
            .pickerStyle(.segmented)

            Stepper("Anzahl Zeichen: \(rule.removeCount)", value: $rule.removeCount, in: 0 ... 100)

        case .caseTransform:
            Picker("Schreibweise", selection: $rule.caseStyle) {
                ForEach(RenameRule.CaseStyle.allCases, id: \.self) { style in
                    Text(style.title).tag(style)
                }
            }

        case .windowsSanitize:
            Toggle("Für Windows unzulässige Zeichen ersetzen", isOn: $rule.replaceReservedCharacters)
        }
    }
}

private struct RuleDropDelegate: DropDelegate {
    let targetRuleID: UUID
    @Binding var draggedRuleID: UUID?
    let moveRuleBefore: (UUID, UUID) -> Void

    func validateDrop(info _: DropInfo) -> Bool {
        draggedRuleID != nil
    }

    func dropEntered(info _: DropInfo) {
        guard let draggedRuleID else {
            return
        }

        moveRuleBefore(draggedRuleID, targetRuleID)
    }

    func performDrop(info _: DropInfo) -> Bool {
        draggedRuleID = nil
        return true
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct RuleActivitySummary: View {
    let activeCount: Int

    var body: some View {
        HStack(spacing: 10) {
            Label(activeCount == 0 ? "Noch keine aktive Regel" : "\(activeCount) aktive Regeln", systemImage: activeCount == 0 ? "slider.horizontal.3" : "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(activeCount == 0 ? Color.secondary : Color.accentColor)

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}
