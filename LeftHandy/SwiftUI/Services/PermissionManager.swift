import Foundation
import Cocoa
import os.log

@MainActor
class PermissionManager {

    static let shared = PermissionManager()

    private(set) var currentStatus = PermissionStatus() {
        didSet {
            if oldValue != currentStatus {
                onPermissionStatusChanged?(currentStatus)
            }
        }
    }

    private(set) var isMonitoring = false {
        didSet {
            if oldValue != isMonitoring {
                onMonitoringStateChanged?(isMonitoring)
            }
        }
    }

    private(set) var lastPermissionCheck: Date? {
        didSet {
            if oldValue != lastPermissionCheck {
                onPermissionCheckTimeChanged?(lastPermissionCheck)
            }
        }
    }

    private var monitoringTimer: Timer?
    private var permissionCheckTimer: Timer?
    private var monitoringCheckCount: Int = 0
    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "PermissionManager"
    )
    private let accessibilityNotificationName = NSNotification.Name("com.apple.accessibility.api")
    private let systemSettingsBundleIDs: Set<String> = [
        "com.apple.systemsettings",
        "com.apple.systempreferences"
    ]


    var onPermissionGranted: (() -> Void)?
    var onPermissionRevoked: (() -> Void)?
    var onPermissionStatusChanged: ((PermissionStatus) -> Void)?
    var onMonitoringStateChanged: ((Bool) -> Void)?
    var onPermissionCheckTimeChanged: ((Date?) -> Void)?


    private init() {
        updatePermissionStatus()
        logger.info("PermissionManager initialized")
    }


    func hasAccessibilityPermission() -> Bool {
        return currentStatus.accessibility.isGranted
    }

    func getPermissionStatus() -> PermissionStatus {
        return currentStatus
    }

    func updatePermissionStatus() {
        let newStatus = PermissionChecker.checkAllPermissions()
        let oldStatus = currentStatus
        currentStatus = newStatus
        lastPermissionCheck = Date()

        if oldStatus.accessibility != newStatus.accessibility {
            handleAccessibilityPermissionChange(
                from: oldStatus.accessibility,
                to: newStatus.accessibility
            )
        }

        logger.debug("Permission status updated: \(newStatus.summary)")
    }


    func startMonitoring() {
        guard !isMonitoring else {
            logger.debug("Permission monitoring already active")
            return
        }

        isMonitoring = true

        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleAccessibilityNotification),
            name: accessibilityNotificationName,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDeactivation(_:)),
            name: NSWorkspace.didDeactivateApplicationNotification,
            object: nil
        )

        permissionCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 10.0,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updatePermissionStatus()
            }
        }

        logger.info("Started permission monitoring (notification + workspace + 10s fallback)")
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        DistributedNotificationCenter.default().removeObserver(
            self,
            name: accessibilityNotificationName,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.removeObserver(
            self,
            name: NSWorkspace.didDeactivateApplicationNotification,
            object: nil
        )

        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
        monitoringTimer?.invalidate()
        monitoringTimer = nil

        isMonitoring = false
        logger.info("Stopped permission monitoring")
    }

    @objc private func handleAccessibilityNotification() {
        logger.info("Accessibility settings changed notification received")
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            self.updatePermissionStatus()
        }
    }

    @objc private func handleAppDeactivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier,
              systemSettingsBundleIDs.contains(bundleID) else { return }

        logger.info("System Settings deactivated, checking permissions")
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            self.updatePermissionStatus()
        }
    }


    func checkAndRequestPermissions(completion: @escaping @Sendable (Bool) -> Void) {
        updatePermissionStatus()

        if currentStatus.allRequiredGranted {
            logger.info("All required permissions granted")
            completion(true)
        } else {
            logger.info("Required permissions missing")
            completion(false)
        }
    }

    func requestAccessibilityPermission() {
        logger.info("Requesting accessibility permission")
        PermissionChecker.requestAccessibilityPermission()
    }

    func handlePermissionRevoked() {
        logger.warning("Permission revoked during runtime")
        onPermissionRevoked?()
    }


    private func handleAccessibilityPermissionChange(
        from oldState: PermissionState,
        to newState: PermissionState
    ) {
        switch (oldState, newState) {
        case (_, .granted):
            logger.info("Accessibility permission granted")
            onPermissionGranted?()

        case (.granted, .denied), (.granted, .unknown):
            logger.warning("Accessibility permission revoked")
            onPermissionRevoked?()

        default:
            logger.debug(
                "Accessibility state changed: \(oldState.rawValue) -> \(newState.rawValue)"
            )
        }
    }
}


extension PermissionManager {

    var hasAllRequiredPermissions: Bool {
        return currentStatus.allRequiredGranted
    }

    var missingPermissionsSummary: String {
        if currentStatus.allRequiredGranted {
            return "All permissions granted"
        }

        var missing: [String] = []

        if !currentStatus.accessibility.isGranted {
            missing.append("Accessibility")
        }

        return "Missing: " + missing.joined(separator: ", ")
    }

    func quickAccessibilityCheck() -> Bool {
        return PermissionChecker.checkAccessibilityPermission().isGranted
    }
}
