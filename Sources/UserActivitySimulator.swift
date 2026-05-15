import Foundation
import CoreGraphics
import AppKit

// Resets HIDIdleTime (what Teams/Electron reads) by posting a synthetic
// mouse-moved CGEvent at the current cursor position every 4 minutes.
// caffeinate -u is NOT sufficient — it only resets the power-management
// sleep timer, not the HID idle counter Teams monitors via IOKit.
// Requires Accessibility permission (Privacy & Security > Accessibility).
class UserActivitySimulator {
    // Overridable for testing
    var isTrusted: () -> Bool = { AXIsProcessTrusted() }
    var requestPermission: () -> Void = { UserActivitySimulator.showPermissionAlert() }
    var postEvent: () -> Void = { UserActivitySimulator.postMouseEvent() }

    private var timer: Timer?
    private var hasRequestedPermission = false
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
        guard !isTrusted() else { return }
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        requestPermission()
    }

    private func fireActivity() {
        guard isTrusted() else { return }
        postEvent()
    }

    private static func showPermissionAlert() {
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

    private static func postMouseEvent() {
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
