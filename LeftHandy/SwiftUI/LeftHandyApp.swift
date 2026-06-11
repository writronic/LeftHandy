import SwiftUI

@main
struct LeftHandyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var viewModel = MenuBarViewModel()

    var body: some Scene {
        MenuBarExtra("LeftHandy", image: "MenuBarIcon") {
            Toggle("Active", isOn: $viewModel.isActive)
                .toggleStyle(.checkbox)

            Toggle("Swap Mouse Buttons", isOn: $viewModel.isSwapMouseButtons)
                .toggleStyle(.checkbox)

            Divider()

            Toggle("Start at Login", isOn: $viewModel.isStartAtLoginEnabled)
            .toggleStyle(.checkbox)

            Divider()

            Button("About LeftHandy") {
                viewModel.showAbout()
            }

            Button("Quit LeftHandy") {
                viewModel.quit()
            }
            .keyboardShortcut("q")
        }
    }
}
