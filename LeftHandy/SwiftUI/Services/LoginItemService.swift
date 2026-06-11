import Foundation
import Cocoa
import os.log

@MainActor
final class LoginItemService {

    static let shared = LoginItemService()

    private(set) var isEnabled: Bool = false

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "LoginItemService"
    )

    private static let launchAgentPlist: NSDictionary = [
        "Label": AppConstants.bundleID,
        "Program": Bundle.main.executablePath ?? "/Applications/LeftHandy.app/Contents/MacOS/LeftHandy",
        "RunAtLoad": true,
        "KeepAlive": false,
        "LimitLoadToSessionType": "Aqua",
        "AssociatedBundleIdentifiers": AppConstants.bundleID,
        "ProcessType": "Interactive",
        "LegacyTimers": true,
    ]

    private init() {
        logger.info("LoginItemService initialized")
        updateStatus()
    }

    func toggle() {
        setEnabled(!isEnabled)
    }

    func setEnabled(_ enabled: Bool) {
        logger.info("Setting start at login to: \(enabled)")

        do {
            try writePlistToDisk(enabled)
            updateStatus()
        } catch {
            logger.error("Failed to set start at login: \(error.localizedDescription)")
        }
    }

    func updateStatus() {
        let plistPath = getLaunchAgentPlistPath()
        let newIsEnabled = FileManager.default.fileExists(atPath: plistPath.path)

        isEnabled = newIsEnabled

        logger.info("Start at login status: \(newIsEnabled ? "enabled" : "disabled")")
    }


    private func writePlistToDisk(_ enabled: Bool) throws {
        var launchAgentsPath = (try? FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )) ?? URL(fileURLWithPath: "~/Library", isDirectory: true)

        launchAgentsPath.appendPathComponent("LaunchAgents", isDirectory: true)

        if !FileManager.default.fileExists(atPath: launchAgentsPath.path) {
            try FileManager.default.createDirectory(at: launchAgentsPath, withIntermediateDirectories: false)
            logger.debug("\(launchAgentsPath.absoluteString) created")
        }

        launchAgentsPath.appendPathComponent("\(AppConstants.bundleID).plist", isDirectory: false)

        if enabled {
            let data = try PropertyListSerialization.data(
                fromPropertyList: Self.launchAgentPlist,
                format: .xml,
                options: 0
            )
            try data.write(to: launchAgentsPath, options: [.atomic])
            logger.debug("\(launchAgentsPath.absoluteString) written")
        } else {
            if FileManager.default.fileExists(atPath: launchAgentsPath.path) {
                try FileManager.default.removeItem(at: launchAgentsPath)
                logger.debug("\(launchAgentsPath.absoluteString) removed")
            }
        }
    }

    private func getLaunchAgentPlistPath() -> URL {
        var launchAgentsPath = (try? FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )) ?? URL(fileURLWithPath: "~/Library", isDirectory: true)

        launchAgentsPath.appendPathComponent("LaunchAgents", isDirectory: true)
        launchAgentsPath.appendPathComponent("\(AppConstants.bundleID).plist", isDirectory: false)

        return launchAgentsPath
    }


}
