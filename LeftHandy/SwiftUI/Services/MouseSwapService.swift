import Foundation
import os.log

@MainActor
final class MouseSwapService {
    static let shared = MouseSwapService()

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "MouseSwapService"
    )

    private init() {}

    func setEnabled(_ enabled: Bool) {
        if enabled {
            let success = LHMouseSwapStart()
            logger.info("Mouse swap started: \(success)")
            if !success {
                logger.error("EventTap creation failed — check Accessibility permissions")
            }
        } else {
            LHMouseSwapStop()
            logger.info("Mouse swap stopped")
        }
    }

    var isRunning: Bool {
        return LHMouseSwapIsRunning()
    }
}
