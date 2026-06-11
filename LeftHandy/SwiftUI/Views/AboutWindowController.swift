import Cocoa
import SwiftUI
import os.log

class AboutWindowController: NSWindowController {

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "AboutWindow"
    )

    convenience init() {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )

        self.init(window: window)
        setupWindow()
    }

    private func setupWindow() {
        guard let window = window else { return }

        window.title = "About \(AppConstants.appName)"
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)

        let hostingController = NSHostingController(rootView: AboutWindowView())
        window.contentViewController = hostingController

        window.setContentSize(hostingController.view.fittingSize)
        window.center()

        logger.info("About window configured")
    }

    func showAbout() {
        guard let window = window else { return }

        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    override func cancelOperation(_ sender: Any?) {
        window?.close()
    }
}
