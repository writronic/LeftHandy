import Foundation
import os.log

@MainActor
final class CursorFlipService {
    static let shared = CursorFlipService()

    private let logger = Logger(
        subsystem: AppConstants.bundleID,
        category: "CursorFlipService"
    )

    private var hasCaptured = false

    private init() {}

    func setEnabled(_ enabled: Bool) {
        if enabled {
            activate()
        } else {
            deactivate()
        }
    }

    private func activate() {
        if !hasCaptured {
            hasCaptured = LHCaptureSystemCursors()
            guard hasCaptured else {
                logger.error("Failed to capture system cursors")
                return
            }
        }

        let success = LHApplyFlippedCursors()
        LHFinalizeCursorApply()
        LHForceCursorVisualRefresh()
        logger.info("Cursor flip activated: \(success)")
    }

    private func deactivate() {
        let success = LHRestoreCursors()
        LHFinalizeCursorApply()
        LHForceCursorVisualRefresh()
        logger.info("Cursors restored: \(success)")
    }
}
