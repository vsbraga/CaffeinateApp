import Foundation

// Periodically declares user activity to the system so apps like MS Teams
// don't transition to "Away" status. Teams reads the system idle timer, which
// caffeinate -u resets without requiring Accessibility permissions or mouse simulation.
class UserActivitySimulator {
    private var timer: Timer?

    var isActive: Bool { timer != nil }

    func start() {
        guard timer == nil else { return }
        fireActivity()
        timer = Timer.scheduledTimer(
            withTimeInterval: Constants.UserActivity.interval,
            repeats: true
        ) { [weak self] _ in self?.fireActivity() }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func fireActivity() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: Constants.CaffeinateProcess.executablePath)
        p.arguments = Constants.UserActivity.arguments
        try? p.run()
    }
}
