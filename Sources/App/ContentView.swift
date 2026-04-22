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
        .frame(minWidth: 1240, minHeight: 760)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(AppInfo.title)
                    .font(.system(size: 28, weight: .bold))
                Text(AppInfo.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("Einfacher Batch Renamer für macOS")
                    .font(.subheadline.weight(.semibold))
                Text("Links Auswahl, Mitte Regeln, rechts Wirkung. Konflikte blockieren die Aktion.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
