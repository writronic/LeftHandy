import Foundation

enum AppConstants {
    static let bundleID = "com.writronic.lefthandy"
    static let appName = "LeftHandy"
    static let copyright = "© 2026 Writronic"

    enum UserDefaultsKeys {
        static let isActive = "LeftHandy_IsActive"
        static let isSwapMouseButtons = "LeftHandy_IsSwapMouseButtons"
        static let hasCompletedOnboarding = "LeftHandy_HasCompletedOnboarding"
        static let firstLaunchDate = "LeftHandy_FirstLaunchDate"
        static let appVersion = "LeftHandy_AppVersion"
        static let launchCount = "LeftHandy_LaunchCount"
    }

    enum Notifications {
        static let permissionWasRevoked = Notification.Name("LeftHandy.permissionWasRevoked")
    }
}
