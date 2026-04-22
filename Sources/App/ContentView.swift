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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 8) {
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

            HStack(spacing: 16) {
                WorkflowStepChip(
                    index: 1,
                    title: "Quellen wählen",
                    subtitle: viewModel.selectionSummary,
                    tint: .secondary,
                    isActive: viewModel.activeStep == 1,
                    isEmphasized: !viewModel.files.isEmpty
                )

                WorkflowStepChip(
                    index: 2,
                    title: "Regeln festlegen",
                    subtitle: viewModel.rulesSummary,
                    tint: .accentColor,
                    isActive: viewModel.activeStep == 2,
                    isEmphasized: viewModel.activeRuleCount > 0
                )

                WorkflowStepChip(
                    index: 3,
                    title: "Vorschau prüfen",
                    subtitle: viewModel.previewSummary,
                    tint: viewModel.errorCount > 0 ? .red : .green,
                    isActive: viewModel.activeStep == 3,
                    isEmphasized: viewModel.hasPreviewContent
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct WorkflowStepChip: View {
    let index: Int
    let title: String
    let subtitle: String
    let tint: Color
    let isActive: Bool
    let isEmphasized: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isActive ? tint.opacity(0.18) : isEmphasized ? tint.opacity(0.14) : Color.secondary.opacity(0.12))
                    .frame(width: 30, height: 30)

                Text("\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isActive || isEmphasized ? tint : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(isActive ? .bold : .semibold))
                    .foregroundStyle(isActive ? .primary : .secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(isActive ? Color.primary.opacity(0.78) : Color.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isActive ? tint.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(alignment: .bottomLeading) {
            Rectangle()
                .fill(isActive ? tint.opacity(0.9) : Color.clear)
                .frame(height: 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(isActive ? tint.opacity(0.16) : Color.secondary.opacity(0.06), lineWidth: 1)
        )
    }
}
