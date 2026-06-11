import Cocoa
import os.log

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    private let firstLaunchManager = FirstLaunchManager.shared
    private var welcomeWindowController: WelcomeWindowController?

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "AppDelegate"
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        firstLaunchManager.recordLaunch()

        if firstLaunchManager.isFirstLaunch {
            showWelcomeWindow()
        } else {
            checkPermissionAndStart()
        }

        logger.info("LeftHandy started successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        LHMouseSwapStop()
        logger.info("LeftHandy terminated")
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    func showWelcomeWindow() {
        if welcomeWindowController != nil {
            welcomeWindowController?.showWelcome()
            return
        }

        logger.info("Showing welcome window")

        welcomeWindowController = WelcomeWindowController()
        welcomeWindowController?.onWelcomeComplete = { [weak self] in
            self?.handleWelcomeComplete()
        }

        welcomeWindowController?.showWelcome()
    }

    private func handleWelcomeComplete() {
        logger.info("Welcome flow completed, starting normal operation")

        firstLaunchManager.markOnboardingCompleted()

        welcomeWindowController?.hideWelcome()
        welcomeWindowController = nil

        startNormalOperation()
    }


    private func checkPermissionAndStart() {
        PermissionManager.shared.updatePermissionStatus()

        if PermissionManager.shared.hasAccessibilityPermission() {
            startNormalOperation()
        } else {
            logger.warning("Accessibility permission not granted, showing welcome window")
            showWelcomeWindow()
        }
    }

    private func startNormalOperation() {
        logger.info("Starting normal app operation")

        PersistenceService.shared.restoreState()
        PersistenceService.shared.startListening()

        PermissionManager.shared.onPermissionRevoked = { [weak self] in
            self?.handlePermissionRevoked()
        }

        PermissionManager.shared.onPermissionGranted = { [weak self] in
            self?.handlePermissionReGranted()
        }

        PermissionManager.shared.startMonitoring()
    }

    private func handlePermissionRevoked() {
        logger.warning("Accessibility permission revoked — stopping services")

        NotificationCenter.default.post(
            name: AppConstants.Notifications.permissionWasRevoked,
            object: nil
        )

        showWelcomeWindow()
    }

    private func handlePermissionReGranted() {
        logger.info("Accessibility permission re-granted")
        PersistenceService.shared.restoreState()
    }
}

