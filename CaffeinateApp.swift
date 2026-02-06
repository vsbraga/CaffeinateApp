import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var caffeinateProcess: Process?
    var isActive = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        updateIcon()
        setupMenu()
    }

    func setupMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Turn On", action: #selector(toggleCaffeinate), keyEquivalent: "")
        toggleItem.target = self
        toggleItem.tag = 1
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func openSettings() {
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

    @objc func showAbout() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 340),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About Caffeinate Toggle"
        window.center()
        window.isReleasedWhenClosed = false

        let contentView = NSView(frame: window.contentView!.bounds)

        // App icon
        let iconView = NSImageView(frame: NSRect(x: 100, y: 220, width: 100, height: 100))
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns") {
            iconView.image = NSImage(contentsOfFile: iconPath)
        }
        iconView.imageScaling = .scaleProportionallyUpOrDown
        contentView.addSubview(iconView)

        // App name
        let nameLabel = NSTextField(labelWithString: "Caffeinate Toggle")
        nameLabel.frame = NSRect(x: 0, y: 190, width: 300, height: 24)
        nameLabel.alignment = .center
        nameLabel.font = NSFont.boldSystemFont(ofSize: 17)
        contentView.addSubview(nameLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "Version 1.0")
        versionLabel.frame = NSRect(x: 0, y: 168, width: 300, height: 18)
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabelColor
        contentView.addSubview(versionLabel)

        // Author
        let authorLabel = NSTextField(labelWithString: "Powered by Victor Braga")
        authorLabel.frame = NSRect(x: 0, y: 140, width: 300, height: 18)
        authorLabel.alignment = .center
        authorLabel.font = NSFont.systemFont(ofSize: 12)
        contentView.addSubview(authorLabel)

        // Centered paragraph style for links
        let centeredStyle = NSMutableParagraphStyle()
        centeredStyle.alignment = .center

        // GitHub link
        let githubLabel = NSTextField(labelWithString: "")
        githubLabel.frame = NSRect(x: 0, y: 112, width: 300, height: 18)
        githubLabel.alignment = .center
        githubLabel.isSelectable = true
        githubLabel.allowsEditingTextAttributes = true
        githubLabel.isBezeled = false
        githubLabel.drawsBackground = false
        let githubURL = "https://github.com/vsbraga/CaffeinateApp"
        let githubAttr = NSMutableAttributedString(string: "GitHub Repository")
        githubAttr.addAttributes([
            .link: githubURL,
            .font: NSFont.systemFont(ofSize: 11),
            .paragraphStyle: centeredStyle
        ], range: NSRange(location: 0, length: githubAttr.length))
        githubLabel.attributedStringValue = githubAttr
        contentView.addSubview(githubLabel)

        // Donate link
        let donateLabel = NSTextField(labelWithString: "")
        donateLabel.frame = NSRect(x: 0, y: 84, width: 300, height: 18)
        donateLabel.alignment = .center
        donateLabel.isSelectable = true
        donateLabel.allowsEditingTextAttributes = true
        donateLabel.isBezeled = false
        donateLabel.drawsBackground = false
        let donateURL = "https://www.paypal.com/donate?business=victorsbraga@yahoo.com.br"
        let donateAttr = NSMutableAttributedString(string: "Donate via PayPal")
        donateAttr.addAttributes([
            .link: donateURL,
            .font: NSFont.systemFont(ofSize: 11),
            .paragraphStyle: centeredStyle
        ], range: NSRange(location: 0, length: donateAttr.length))
        donateLabel.attributedStringValue = donateAttr
        contentView.addSubview(donateLabel)

        // Separator
        let separator = NSBox(frame: NSRect(x: 20, y: 60, width: 260, height: 1))
        separator.boxType = .separator
        contentView.addSubview(separator)

        // Copyright
        let copyrightLabel = NSTextField(labelWithString: "\u{00A9} 2026 Victor Braga. All Rights Reserved.")
        copyrightLabel.frame = NSRect(x: 0, y: 30, width: 300, height: 18)
        copyrightLabel.alignment = .center
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = .tertiaryLabelColor
        contentView.addSubview(copyrightLabel)

        window.contentView = contentView
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func updateIcon() {
        if let button = statusItem.button {
            let iconSize = NSSize(width: 18, height: 18)
            let icon = NSImage(size: iconSize, flipped: false) { rect in
                // Use menu bar foreground color so it adapts to light/dark automatically
                let fgColor = NSColor(named: "labelColor") ?? NSColor.white
                fgColor.setStroke()

                let lineWidth: CGFloat = 1.2

                // Cup body
                let cupBody = NSBezierPath(roundedRect: NSRect(x: 1, y: 3, width: 9, height: 10), xRadius: 1.5, yRadius: 1.5)
                cupBody.lineWidth = lineWidth
                cupBody.stroke()

                // Cup handle
                let handle = NSBezierPath()
                handle.lineWidth = lineWidth
                handle.appendArc(
                    withCenter: NSPoint(x: 10, y: 9),
                    radius: 2.5,
                    startAngle: -60,
                    endAngle: 60,
                    clockwise: false
                )
                handle.stroke()

                // Steam — two small wiggly lines
                fgColor.withAlphaComponent(0.8).setStroke()
                let steam1 = NSBezierPath()
                steam1.lineWidth = 0.9
                steam1.move(to: NSPoint(x: 4, y: 13.5))
                steam1.curve(to: NSPoint(x: 4, y: 17),
                             controlPoint1: NSPoint(x: 2.5, y: 15),
                             controlPoint2: NSPoint(x: 5.5, y: 15.5))
                steam1.stroke()

                let steam2 = NSBezierPath()
                steam2.lineWidth = 0.9
                steam2.move(to: NSPoint(x: 7.5, y: 13.5))
                steam2.curve(to: NSPoint(x: 7.5, y: 17),
                             controlPoint1: NSPoint(x: 6, y: 15),
                             controlPoint2: NSPoint(x: 9, y: 15.5))
                steam2.stroke()

                // Status indicator dot — bottom-right corner
                let dotSize: CGFloat = 5.0
                let dotRect = NSRect(x: 13, y: 0, width: dotSize, height: dotSize)
                let statusColor: NSColor = self.isActive
                    ? NSColor(red: 0.15, green: 0.82, blue: 0.26, alpha: 1.0)
                    : NSColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0)
                statusColor.setFill()
                NSBezierPath(ovalIn: dotRect).fill()

                return true
            }
            icon.isTemplate = false
            button.image = icon
        }

        // Update menu item text
        if let menu = statusItem.menu, let toggleItem = menu.item(withTag: 1) {
            toggleItem.title = isActive ? "Turn Off" : "Turn On"
        }
    }

    @objc func toggleCaffeinate() {
        if isActive {
            stopCaffeinate()
        } else {
            startCaffeinate()
        }
    }

    func startCaffeinate() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-d"]

        do {
            try process.run()
            caffeinateProcess = process
            isActive = true
            updateIcon()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Failed to start caffeinate: \(error.localizedDescription)"
            alert.runModal()
        }
    }

    func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess = nil
        isActive = false
        updateIcon()
    }

    @objc func quitApp() {
        stopCaffeinate()
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopCaffeinate()
    }
}
