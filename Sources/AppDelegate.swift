import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, CaffeinateManagerDelegate {
    private(set) var statusBar: StatusBarController!
    private(set) var caffeinateManager = CaffeinateManager()
    private(set) var userActivitySimulator = UserActivitySimulator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        caffeinateManager.delegate = self

        statusBar = StatusBarController()
        statusBar.onToggle = { [weak self] in self?.caffeinateManager.toggle() }
        statusBar.onSettings = { SettingsController.showSettings() }
        statusBar.onAbout = { AboutWindowController.shared.show() }
        statusBar.onQuit = { [weak self] in self?.quitApp() }
    }

    // MARK: - CaffeinateManagerDelegate

    func caffeinateManagerDidStart(_ manager: CaffeinateManager) {
        statusBar.updateState(isActive: true)
        userActivitySimulator.start()
    }

    func caffeinateManagerDidStop(_ manager: CaffeinateManager) {
        statusBar.updateState(isActive: false)
        userActivitySimulator.stop()
    }

    func caffeinateManager(_ manager: CaffeinateManager, didFailWithError error: Error) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = "Failed to start caffeinate: \(error.localizedDescription)"
        alert.runModal()
    }

    // MARK: - App Lifecycle

    @objc func quitApp() {
        caffeinateManager.stop()
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        caffeinateManager.stop()
    }
}
