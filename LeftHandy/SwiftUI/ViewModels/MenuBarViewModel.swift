import Foundation
import SwiftUI
import Cocoa
import os.log

@Observable
@MainActor
final class MenuBarViewModel {


    var isActive: Bool = false {
        didSet {
            guard oldValue != isActive else { return }
            if isActive {
                guard PermissionManager.shared.hasAccessibilityPermission() else {
                    logger.warning("Accessibility not granted — blocking activation")
                    isActive = false
                    showPermissionRequiredAlert()
                    return
                }
            }
            logger.info("Active state changed: \(self.isActive)")
            CursorFlipService.shared.setEnabled(isActive)
            UserDefaults.standard.set(isActive, forKey: AppConstants.UserDefaultsKeys.isActive)
        }
    }

    var isSwapMouseButtons: Bool = false {
        didSet {
            guard oldValue != isSwapMouseButtons else { return }
            if isSwapMouseButtons {
                guard PermissionManager.shared.hasAccessibilityPermission() else {
                    logger.warning("Accessibility not granted — blocking swap")
                    isSwapMouseButtons = false
                    showPermissionRequiredAlert()
                    return
                }
            }
            logger.info("Swap Mouse Buttons changed: \(self.isSwapMouseButtons)")
            MouseSwapService.shared.setEnabled(isSwapMouseButtons)
            UserDefaults.standard.set(isSwapMouseButtons, forKey: AppConstants.UserDefaultsKeys.isSwapMouseButtons)
        }
    }

    var isStartAtLoginEnabled: Bool = false {
        didSet {
            guard oldValue != isStartAtLoginEnabled else { return }
            loginItemService.setEnabled(isStartAtLoginEnabled)
            logger.info("Start at Login toggled: \(self.isStartAtLoginEnabled)")
        }
    }

    func refreshLoginItemStatus() {
        loginItemService.updateStatus()
        isStartAtLoginEnabled = loginItemService.isEnabled
    }


    private let loginItemService = LoginItemService.shared
    private var aboutWindowController: AboutWindowController?
    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "MenuBarViewModel"
    )


    init() {
        isActive = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isActive)
        isSwapMouseButtons = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isSwapMouseButtons)
        isStartAtLoginEnabled = loginItemService.isEnabled

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePermissionRevoked),
            name: AppConstants.Notifications.permissionWasRevoked,
            object: nil
        )

        logger.info("MenuBarViewModel initialized — active: \(self.isActive), swap: \(self.isSwapMouseButtons), startAtLogin: \(self.isStartAtLoginEnabled)")
    }

    @objc private func handlePermissionRevoked() {
        logger.warning("Permission revoked — resetting active state")
        isActive = false
        isSwapMouseButtons = false
    }


    func toggleActive() {
        isActive.toggle()
    }

    func toggleSwapMouseButtons() {
        isSwapMouseButtons.toggle()
    }

    func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showAbout()
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func showPermissionRequiredAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "\(AppConstants.appName) needs Accessibility permission to modify cursors and capture mouse events."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            PermissionChecker.openSystemPreferences(for: .accessibility)
        }
    }
}
