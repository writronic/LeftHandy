import Foundation
import Cocoa
@preconcurrency import ApplicationServices


enum PermissionState: String, CaseIterable, Sendable {
    case unknown = "unknown"
    case granted = "granted"
    case denied = "denied"
    case restricted = "restricted"

    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .granted: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        }
    }

    var isGranted: Bool {
        return self == .granted
    }

    var needsUserAction: Bool {
        return self == .denied || self == .unknown
    }
}


struct PermissionStatus: Equatable, Sendable {
    let accessibility: PermissionState
    let lastChecked: Date

    init(accessibility: PermissionState = .unknown,
         lastChecked: Date = Date()) {
        self.accessibility = accessibility
        self.lastChecked = lastChecked
    }

    var allRequiredGranted: Bool {
        return accessibility == .granted
    }

    var hasAnyDenied: Bool {
        return accessibility == .denied
    }

    var summary: String {
        if allRequiredGranted {
            return "All permissions granted"
        }
        return "Accessibility: \(accessibility.displayName)"
    }
}


enum PermissionType: String, CaseIterable, Sendable {
    case accessibility = "accessibility"

    var info: PermissionInfo {
        switch self {
        case .accessibility:
            return .accessibility
        }
    }
}


struct PermissionInfo: Sendable {
    let type: PermissionType
    let title: String
    let description: String
    let reason: String
    let systemPreferencesPane: String?
    let isRequired: Bool

    static let accessibility = PermissionInfo(
        type: .accessibility,
        title: "Accessibility",
        description: "Allows LeftHandy to flip cursors and swap mouse buttons",
        reason: "Required for CGEventTap (mouse swap) and CGS cursor APIs",
        systemPreferencesPane: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
        isRequired: true
    )
}


class PermissionChecker {

    static func checkAllPermissions() -> PermissionStatus {
        return PermissionStatus(
            accessibility: checkAccessibilityPermission(),
            lastChecked: Date()
        )
    }

    static func checkAccessibilityPermission() -> PermissionState {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: false]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if !isTrusted {
            return .denied
        }

        let testMask = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
        guard let testTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: testMask,
            callback: { _, _, event, _ in Unmanaged.passUnretained(event) },
            userInfo: nil
        ) else {
            return .denied
        }
        CFMachPortInvalidate(testTap)

        return .granted
    }

    static func requestAccessibilityPermission() {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    static func openSystemPreferences(for permissionType: PermissionType) {
        guard let urlString = permissionType.info.systemPreferencesPane,
              let url = URL(string: urlString) else {
            let fallbackURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!
            NSWorkspace.shared.open(fallbackURL)
            return
        }

        NSWorkspace.shared.open(url)
    }
}
