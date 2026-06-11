import Foundation
import Cocoa
import os.log

@MainActor
final class PersistenceService {
    static let shared = PersistenceService()

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "PersistenceService"
    )

    private var isListening = false
    private var debounceTask: Task<Void, Never>?

    private init() {}

    func startListening() {
        guard !isListening else { return }

        CGDisplayRegisterReconfigurationCallback({ _, _, _ in
            Task { @MainActor in
                PersistenceService.shared.handleSystemEvent(reason: "Display reconfiguration")
            }
        }, nil)

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleAppActivation()
            }
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleSystemEvent(reason: "Wake from sleep")
            }
        }

        isListening = true
        logger.info("PersistenceService started listening")
    }

    private func handleSystemEvent(reason: String) {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            guard PermissionManager.shared.hasAccessibilityPermission() else { return }

            let isActive = UserDefaults.standard.bool(
                forKey: AppConstants.UserDefaultsKeys.isActive
            )

            if isActive {
                logger.info("\(reason) — reapplying cursor flip")
                CursorFlipService.shared.setEnabled(true)
            }
        }
    }

    private func handleAppActivation() {
        guard PermissionManager.shared.hasAccessibilityPermission() else { return }

        let isActive = UserDefaults.standard.bool(
            forKey: AppConstants.UserDefaultsKeys.isActive
        )

        if isActive {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                LHFinalizeCursorApply()
            }
        }
    }

    func restoreState() {
        guard PermissionManager.shared.hasAccessibilityPermission() else {
            logger.warning("Accessibility not granted — skipping state restore")
            return
        }

        let isActive = UserDefaults.standard.bool(
            forKey: AppConstants.UserDefaultsKeys.isActive
        )
        let isSwapEnabled = UserDefaults.standard.bool(
            forKey: AppConstants.UserDefaultsKeys.isSwapMouseButtons
        )

        if isActive {
            logger.info("Restoring cursor flip on launch")
            CursorFlipService.shared.setEnabled(true)
        }

        if isSwapEnabled {
            logger.info("Restoring mouse swap on launch")
            MouseSwapService.shared.setEnabled(true)
        }
    }
}
