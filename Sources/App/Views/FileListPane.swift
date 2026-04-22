import SwiftUI

struct FileListPane: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Dateiquellen")
                    .font(.headline)
                Spacer()
                Button("Dateien") {
                    viewModel.importFiles()
                }
                Button("Ordner") {
                    viewModel.importFolders()
                }
            }

            DropZoneView(isEmpty: viewModel.files.isEmpty)
                .onDrop(of: viewModel.allowedDropTypes, isTargeted: nil, perform: viewModel.handleDropped)

            HStack {
                Label("\(viewModel.files.count) Dateien", systemImage: "doc.on.doc")
                Spacer()
                Label("\(viewModel.selectedCount) ausgewählt", systemImage: "checkmark.circle")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if viewModel.files.isEmpty {
                Spacer()
            } else {
                List {
                    ForEach(viewModel.previews) { preview in
                        HStack(alignment: .top, spacing: 12) {
                            Toggle("", isOn: selectionBinding(for: preview.id))
                                .toggleStyle(.checkbox)
                                .labelsHidden()

                            VStack(alignment: .leading, spacing: 4) {
                                Text(preview.source.originalFilename)
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)

                                Text(preview.source.displayDirectory)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(preview.validationSummary)
                                .font(.caption)
                                .foregroundStyle(preview.hasErrors ? .red : .secondary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: viewModel.removeFiles)
                }
                .listStyle(.plain)
            }

            HStack {
                Button("Liste leeren", role: .destructive) {
                    viewModel.clearFiles()
                }
                .disabled(viewModel.files.isEmpty)
                Spacer()
            }
        }
        .padding(20)
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }

    private func selectionBinding(for fileID: UUID) -> Binding<Bool> {
        Binding(
            get: { viewModel.files.first(where: { $0.id == fileID })?.isSelected ?? false },
            set: { _ in
                DispatchQueue.main.async {
                    viewModel.toggleSelection(for: fileID)
                }
            }
        )
    }
}

private struct DropZoneView: View {
    let isEmpty: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.accentColor)

                    Text(isEmpty ? "Dateien oder Ordner hier hineinziehen" : "Weitere Dateien oder Ordner hinzufügen")
                        .font(.body.weight(.medium))

                    Text("Ordner werden im MVP flach eingelesen. Dateiendungen bleiben standardmäßig unberührt.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            }
            .frame(height: 140)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            )
    }
}
