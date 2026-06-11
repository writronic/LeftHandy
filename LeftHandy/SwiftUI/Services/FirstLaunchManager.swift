import Foundation
import os.log

@MainActor
class FirstLaunchManager {

    static let shared = FirstLaunchManager()
    private init() {}

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "FirstLaunchManager"
    )


    var isFirstLaunch: Bool {
        return !UserDefaults.standard.bool(
            forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding
        )
    }

    var hasCompletedOnboarding: Bool {
        return UserDefaults.standard.bool(
            forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding
        )
    }

    var firstLaunchDate: Date? {
        return UserDefaults.standard.object(
            forKey: AppConstants.UserDefaultsKeys.firstLaunchDate
        ) as? Date
    }

    var launchCount: Int {
        return UserDefaults.standard.integer(
            forKey: AppConstants.UserDefaultsKeys.launchCount
        )
    }

    var firstLaunchAppVersion: String? {
        return UserDefaults.standard.string(
            forKey: AppConstants.UserDefaultsKeys.appVersion
        )
    }


    func recordLaunch() {
        let currentLaunchCount = launchCount
        let newLaunchCount = currentLaunchCount + 1

        UserDefaults.standard.set(
            newLaunchCount,
            forKey: AppConstants.UserDefaultsKeys.launchCount
        )

        if currentLaunchCount == 0 {
            UserDefaults.standard.set(
                Date(),
                forKey: AppConstants.UserDefaultsKeys.firstLaunchDate
            )

            if let appVersion = getCurrentAppVersion() {
                UserDefaults.standard.set(
                    appVersion,
                    forKey: AppConstants.UserDefaultsKeys.appVersion
                )
            }

            logger.info(
                "First launch recorded — version: \(self.getCurrentAppVersion() ?? "unknown")"
            )
        }

        logger.debug("Launch count updated: \(newLaunchCount)")
    }

    func markOnboardingCompleted() {
        UserDefaults.standard.set(
            true,
            forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding
        )
        logger.info("Onboarding marked as completed")
    }

    func isVersionUpgrade() -> Bool {
        guard let firstVersion = firstLaunchAppVersion,
              let currentVersion = getCurrentAppVersion() else {
            return false
        }
        return firstVersion != currentVersion
    }

    private func getCurrentAppVersion() -> String? {
        return Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
    }
}
