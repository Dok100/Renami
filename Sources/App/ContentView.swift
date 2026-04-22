import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            HSplitView {
                FileListPane(viewModel: viewModel)
                RuleEditorPane(viewModel: viewModel)
                PreviewPane(viewModel: viewModel)
            }
        }
        .frame(minWidth: 1280, minHeight: 800)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppInfo.title)
                        .font(.system(size: 30, weight: .bold))
                    Text(AppInfo.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Sicherer Ablauf")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(viewModel.renameHelpText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 380, alignment: .trailing)
                }
            }

            HStack(spacing: 12) {
                WorkflowStepChip(
                    index: 1,
                    title: "Quellen wählen",
                    subtitle: viewModel.selectionSummary,
                    tint: .secondary,
                    isEmphasized: !viewModel.files.isEmpty
                )

                WorkflowStepChip(
                    index: 2,
                    title: "Regeln festlegen",
                    subtitle: viewModel.rulesSummary,
                    tint: .accentColor,
                    isEmphasized: viewModel.activeRuleCount > 0
                )

                WorkflowStepChip(
                    index: 3,
                    title: "Vorschau prüfen",
                    subtitle: viewModel.previewSummary,
                    tint: viewModel.errorCount > 0 ? .red : .green,
                    isEmphasized: viewModel.hasPreviewContent
                )
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct WorkflowStepChip: View {
    let index: Int
    let title: String
    let subtitle: String
    let tint: Color
    let isEmphasized: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isEmphasized ? tint.opacity(0.14) : Color.secondary.opacity(0.12))
                    .frame(width: 30, height: 30)

                Text("\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isEmphasized ? tint : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}
