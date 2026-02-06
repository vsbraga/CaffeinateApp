import Cocoa

class StatusBarController {
    let statusItem: NSStatusItem
    var onToggle: (() -> Void)?
    var onSettings: (() -> Void)?
    var onAbout: (() -> Void)?
    var onQuit: (() -> Void)?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMenu()
        updateState(isActive: false)

        if let button = statusItem.button {
            button.toolTip = "Caffeinate Toggle"
            button.setAccessibilityLabel("Caffeinate Toggle - Inactive")
        }
    }

    func setupMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: Constants.Menu.turnOn,
            action: #selector(handleToggle),
            keyEquivalent: ""
        )
        toggleItem.target = self
        toggleItem.tag = Constants.Menu.toggleTag
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: Constants.Menu.settings,
            action: #selector(handleSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(
            title: Constants.Menu.about,
            action: #selector(handleAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        let quitItem = NSMenuItem(
            title: Constants.Menu.quit,
            action: #selector(handleQuit),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func updateState(isActive: Bool) {
        if let button = statusItem.button {
            button.image = IconRenderer.render(isActive: isActive)
            let stateLabel = isActive ? "Active" : "Inactive"
            button.setAccessibilityLabel("Caffeinate Toggle - \(stateLabel)")
        }
        if let menu = statusItem.menu, let toggleItem = menu.item(withTag: Constants.Menu.toggleTag) {
            toggleItem.title = isActive ? Constants.Menu.turnOff : Constants.Menu.turnOn
        }
    }

    // MARK: - Menu Actions

    @objc private func handleToggle() { onToggle?() }
    @objc private func handleSettings() { onSettings?() }
    @objc private func handleAbout() { onAbout?() }
    @objc private func handleQuit() { onQuit?() }
}
