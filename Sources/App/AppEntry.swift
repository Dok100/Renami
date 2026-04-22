import SwiftUI

@main
struct RenamiApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1360, height: 820)
    }
}
