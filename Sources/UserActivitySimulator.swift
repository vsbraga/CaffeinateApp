import Foundation
import CoreGraphics
import AppKit

// Resets the HIDIdleTime counter (what Teams reads) by posting a synthetic
// mouse-moved event at the current cursor position every 4 minutes.
// caffeinate -u is NOT sufficient — it only affects the power management
// sleep timer, not the HID idle counter Teams monitors.
// Requires Accessibility permission (Privacy & Security > Accessibility).
class UserActivitySimulator {
    private var timer: Timer?

    var isActive: Bool { timer != nil }

    func start() {
        guard timer == nil else { return }
        requestAccessibilityIfNeeded()
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

    private func requestAccessibilityIfNeeded() {
        guard !AXIsProcessTrusted() else { return }
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Needed"
            alert.informativeText = "To keep your Teams status active, Caffeinate Toggle needs Accessibility access.\n\nClick Open Settings, then add this app under Privacy & Security › Accessibility."
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Later")
            NSApp.activate(ignoringOtherApps: true)
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(
                    URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                )
            }
        }
    }

    private func fireActivity() {
        guard AXIsProcessTrusted() else { return }
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let mousePos = NSEvent.mouseLocation
        let point = CGPoint(x: mousePos.x, y: screenHeight - mousePos.y)
        guard let event = CGEvent(
            mouseEventSource: CGEventSource(stateID: .hidSystemState),
            mouseType: .mouseMoved,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else { return }
        event.post(tap: .cghidEventTap)
    }
}
