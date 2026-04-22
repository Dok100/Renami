import SwiftUI

struct PreviewPane: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            summaryBar
            filterBar

            if !viewModel.hasPreviewContent {
                emptyState
                Spacer()
            } else if viewModel.displayedPreviews.isEmpty {
                filteredEmptyState
                Spacer()
            } else {
                previewTable
            }

            approvalBar
        }
        .padding(16)
        .frame(minWidth: 480, idealWidth: 560, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .top) {
            if viewModel.activeStep == 3 {
                Rectangle()
                    .foregroundStyle(Color.accentColor.opacity(0.35))
                    .frame(height: 2)
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("3")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(viewModel.errorCount > 0 ? .red : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill((viewModel.errorCount > 0 ? Color.red : Color.green).opacity(0.12)))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Vorschau und Freigabe")
                        .font(.title3.weight(.semibold))
                    Text("Vergleiche alten und neuen Namen, prüfe Konflikte und starte erst dann die Umbenennung.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var summaryBar: some View {
        HStack(spacing: 8) {
            SummaryChip(title: "Änderungen", value: "\(viewModel.changedCount)", tint: .accentColor)
            SummaryChip(title: "Konflikte", value: "\(viewModel.errorCount)", tint: viewModel.errorCount > 0 ? .red : .secondary)
            SummaryChip(title: "Unverändert", value: "\(viewModel.unchangedCount)", tint: .secondary)
            Spacer()
        }
    }

    private var filterBar: some View {
        HStack {
            Picker("Ansicht", selection: previewListModeBinding) {
                ForEach(AppViewModel.PreviewListMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 340)

            Spacer()

            if viewModel.errorCount > 0 {
                Label("Konflikte zuerst beheben", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }
        }
    }

    private var previewTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text("Original")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Neuer Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Status")
                    .frame(width: 150, alignment: .leading)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor))

            List(viewModel.displayedPreviews) { preview in
                PreviewRow(preview: preview)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Noch keine Vorschau",
            systemImage: "eye",
            description: Text(viewModel.previewSummary)
        )
    }

    private var filteredEmptyState: some View {
        ContentUnavailableView(
            "Nichts für diesen Filter",
            systemImage: "line.3.horizontal.decrease.circle",
            description: Text("Die aktuelle Ansicht enthält keine Einträge. Wechsle auf „Alle“ oder passe die Regeln an.")
        )
    }

    private var approvalBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.statusMessage)
                        .font(.subheadline.weight(.semibold))
                    Text(viewModel.renameHelpText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.canUndoLastRename {
                    Button(viewModel.undoButtonTitle) {
                        DispatchQueue.main.async {
                            viewModel.undoLastRename()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button(viewModel.renameButtonTitle) {
                    DispatchQueue.main.async {
                        viewModel.requestRename()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.canRename)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var previewListModeBinding: Binding<AppViewModel.PreviewListMode> {
        Binding(
            get: { viewModel.previewListMode },
            set: { mode in
                DispatchQueue.main.async {
                    viewModel.selectPreviewListMode(mode)
                }
            }
        )
    }
}

private struct PreviewRow: View {
    let preview: PreviewItem

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preview.source.originalFilename)
                    .font(.body)
                    .lineLimit(1)
                    .help(preview.source.originalFilename)
                Text(preview.source.displayDirectory)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .help(preview.source.displayDirectory)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(preview.targetFilename)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(preview.hasErrors ? .red : .primary)
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .help(preview.targetFilename)

                if preview.hasErrors {
                    Text(preview.validationSummary)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                        .help(preview.validationSummary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                StatusPill(status: preview.status)

                Text(statusDetail)
                    .font(.caption)
                    .foregroundStyle(preview.hasErrors ? .red : .secondary)
                    .lineLimit(2)
            }
            .frame(width: 150, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(rowBackground)
    }

    private var statusDetail: String {
        switch preview.status {
        case .conflict:
            preview.validationSummary
        case .changed:
            "Bereit"
        case .unchanged:
            "Keine Änderung"
        }
    }

    private var rowBackground: some View {
        Group {
            switch preview.status {
            case .conflict:
                Color.red.opacity(0.06)
            case .changed:
                Color.accentColor.opacity(0.035)
            case .unchanged:
                Color.clear
            }
        }
    }
}

private struct SummaryChip: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.08))
        )
    }
}
