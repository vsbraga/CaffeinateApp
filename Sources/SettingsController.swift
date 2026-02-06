import Cocoa
import ServiceManagement

enum SettingsController {

    static func showSettings() {
        let alert = NSAlert()
        alert.messageText = "Settings"
        alert.alertStyle = .informational

        let checkbox = NSButton(checkboxWithTitle: "Launch at startup", target: nil, action: nil)
        if #available(macOS 13.0, *) {
            checkbox.state = SMAppService.mainApp.status == .enabled ? .on : .off
        } else {
            checkbox.state = .off
        }
        alert.accessoryView = checkbox
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            let shouldLaunch = checkbox.state == .on
            if #available(macOS 13.0, *) {
                do {
                    if shouldLaunch {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    let errAlert = NSAlert()
                    errAlert.messageText = "Error"
                    errAlert.informativeText = "Could not update login item: \(error.localizedDescription)"
                    errAlert.runModal()
                }
            }
        }
    }
}
