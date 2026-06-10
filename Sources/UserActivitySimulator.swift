import Foundation
import IOKit.pwr_mgt

// Resets the system display-idle timer every 4 minutes via IOPMAssertionDeclareUserActivity.
// This is the correct API for simulating user presence: no cursor movement, no keyboard
// events, no Accessibility permission required. Teams/Slack/Electron read HIDIdleTime via
// IOKit; IOPMAssertionDeclareUserActivity resets that counter directly.
class UserActivitySimulator {
    var declareActivity: () -> Void = { UserActivitySimulator.resetIdleTimer() }

    private var timer: Timer?
    var isActive: Bool { timer != nil }

    func start() {
        guard timer == nil else { return }
        declareActivity()
        timer = Timer.scheduledTimer(
            withTimeInterval: Constants.UserActivity.interval,
            repeats: true
        ) { [weak self] _ in self?.declareActivity() }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private static func resetIdleTimer() {
        var assertionID: IOPMAssertionID = 0
        IOPMAssertionDeclareUserActivity("Caffeinate Toggle keep-alive" as CFString, kIOPMUserActiveLocal, &assertionID)
    }
}
