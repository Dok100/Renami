import SwiftUI

struct PreviewPane: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Vorschau & Validierung")
                    .font(.headline)
                Spacer()
                SummaryChip(title: "Änderungen", value: "\(viewModel.changedCount)", tint: .accentColor)
                SummaryChip(title: "Konflikte", value: "\(viewModel.errorCount)", tint: viewModel.errorCount > 0 ? .red : .green)
            }

            Picker("Ansicht", selection: previewListModeBinding) {
                ForEach(AppViewModel.PreviewListMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.previews.isEmpty {
                ContentUnavailableView(
                    "Noch keine Vorschau",
                    systemImage: "eye",
                    description: Text("Importiere Dateien und aktiviere Regeln, um Vorher und Nachher direkt zu vergleichen.")
                )
                Spacer()
            } else {
                List(viewModel.displayedPreviews) { preview in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: preview.hasErrors ? "exclamationmark.triangle.fill" : "arrow.left.arrow.right")
                            .foregroundStyle(preview.hasErrors ? .red : .secondary)
                            .frame(width: 18)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(preview.source.originalFilename)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(preview.targetFilename)
                                .font(.body.weight(.medium))
                                .foregroundStyle(preview.hasErrors ? .red : .primary)
                                .textSelection(.enabled)
                        }

                        Spacer()

                        Text(preview.validationSummary)
                            .font(.caption)
                            .foregroundStyle(preview.hasErrors ? .red : .secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }

            Divider()

            HStack {
                Text(viewModel.statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Umbenennen") {
                    DispatchQueue.main.async {
                        viewModel.requestRename()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.canRename)
            }
        }
        .padding(20)
        .frame(minWidth: 420, idealWidth: 500, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(0.08))
        )
    }
}
