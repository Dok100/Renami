import SwiftUI

struct FileListPane: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            importOptionsPanel
            sourceSummary
            if !viewModel.files.isEmpty {
                filterBar
            }
            DropZoneView(isEmpty: viewModel.files.isEmpty)
                .onDrop(of: viewModel.allowedDropTypes, isTargeted: nil, perform: viewModel.handleDropped)

            if viewModel.files.isEmpty {
                emptyHelper
                Spacer()
            } else if viewModel.displayedSourcePreviews.isEmpty {
                filteredEmptyState
                Spacer()
            } else {
                List(viewModel.displayedSourcePreviews) { preview in
                    FileRow(
                        preview: preview,
                        isSelected: selectionBinding(for: preview.id)
                    )
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            footer
        }
        .padding(16)
        .frame(minWidth: 300, idealWidth: 340, maxWidth: 380, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .top) {
            if viewModel.activeStep == 1 {
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
                Text("1")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.secondary.opacity(0.12)))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Quellen")
                        .font(.title3.weight(.semibold))
                    Text("Dateien oder Ordner hinzufügen und Auswahl eingrenzen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Button {
                    viewModel.importFiles()
                } label: {
                    Label("Dateien", systemImage: "doc.badge.plus")
                }

                Button {
                    viewModel.importFolders()
                } label: {
                    Label("Ordner", systemImage: "folder.badge.plus")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
    }

    private var sourceSummary: some View {
        HStack(spacing: 8) {
            SourceMetric(title: "Quellen", value: "\(viewModel.files.count)", systemImage: "doc.on.doc")
            SourceMetric(title: "Auswahl", value: "\(viewModel.selectedCount)", systemImage: "checkmark.circle")
        }
    }

    private var importOptionsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ordnerimport")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Toggle("Unterordner einbeziehen", isOn: includeSubfoldersBinding)

            HStack(spacing: 8) {
                Text("Dateitypen")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Picker("Dateitypen", selection: fileTypeFilterBinding) {
                    ForEach(FileImportService.FileTypeFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 170)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var emptyHelper: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("So startest du", systemImage: "lightbulb")
                .font(.subheadline.weight(.semibold))
            Text("Ziehe Dateien in die Ablage oder füge sie über die Buttons oben hinzu. Die Vorschau bleibt bewusst leer, bis Regeln aktiv sind.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Keine Einträge für diesen Filter", systemImage: "line.3.horizontal.decrease.circle")
                .font(.subheadline.weight(.semibold))
            Text("Wechsle auf „Alle“ oder passe Regeln und Auswahl an, um wieder Dateien in der Quellenliste zu sehen.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ansicht")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Quellenfilter", selection: sourceListModeBinding) {
                ForEach(AppViewModel.SourceListMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var footer: some View {
        HStack {
            Button("Liste leeren", role: .destructive) {
                viewModel.clearFiles()
            }
            .disabled(viewModel.files.isEmpty)

            Spacer()

            Text(viewModel.selectionSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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

    private var sourceListModeBinding: Binding<AppViewModel.SourceListMode> {
        Binding(
            get: { viewModel.sourceListMode },
            set: { mode in
                DispatchQueue.main.async {
                    viewModel.selectSourceListMode(mode)
                }
            }
        )
    }

    private var includeSubfoldersBinding: Binding<Bool> {
        Binding(
            get: { viewModel.includesSubfolders },
            set: { value in
                DispatchQueue.main.async {
                    viewModel.setIncludesSubfolders(value)
                }
            }
        )
    }

    private var fileTypeFilterBinding: Binding<FileImportService.FileTypeFilter> {
        Binding(
            get: { viewModel.folderFileTypeFilter },
            set: { filter in
                DispatchQueue.main.async {
                    viewModel.setFolderFileTypeFilter(filter)
                }
            }
        )
    }
}

private struct FileRow: View {
    let preview: PreviewItem
    let isSelected: Binding<Bool>
    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Toggle("", isOn: isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(preview.source.originalFilename)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                        .help(preview.source.originalFilename)

                    StatusPill(status: preview.status)
                }

                if isHovering || preview.hasErrors {
                    Text(preview.source.displayDirectory)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .help(preview.source.displayDirectory)
                }

                if preview.hasErrors {
                    Text(preview.validationSummary)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                        .help(preview.validationSummary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovering ? Color.secondary.opacity(0.06) : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

private struct SourceMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

private struct DropZoneView: View {
    let isEmpty: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.7))
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.accentColor)

                    Text(isEmpty ? "Dateien oder Ordner hier ablegen" : "Weitere Quellen hinzufügen")
                        .font(.headline)

                    Text("Dateiendungen bleiben standardmäßig unberührt. Ordner werden aktuell flach eingelesen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(22)
            }
            .frame(height: isEmpty ? 150 : 110)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            )
    }
}

struct StatusPill: View {
    let status: PreviewItem.Status

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(background))
    }

    private var title: String {
        switch status {
        case .conflict:
            "Konflikt"
        case .changed:
            "Geändert"
        case .unchanged:
            "Unverändert"
        }
    }

    private var foreground: Color {
        switch status {
        case .conflict:
            .red
        case .changed:
            .accentColor
        case .unchanged:
            .secondary
        }
    }

    private var background: Color {
        switch status {
        case .conflict:
            .red.opacity(0.12)
        case .changed:
            .accentColor.opacity(0.12)
        case .unchanged:
            .secondary.opacity(0.12)
        }
    }
}
