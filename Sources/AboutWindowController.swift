import Cocoa

class AboutWindowController {
    static let shared = AboutWindowController()

    private var window: NSWindow?

    func show() {
        if let existingWindow = window, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let newWindow = NSWindow(
            contentRect: Constants.About.windowSize,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = Constants.About.windowTitle
        newWindow.center()
        newWindow.isReleasedWhenClosed = false

        let contentView = NSView(frame: newWindow.contentView!.bounds)

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

        // Version (read from bundle)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let versionLabel = NSTextField(labelWithString: "Version \(version)")
        versionLabel.frame = NSRect(x: 0, y: 168, width: 300, height: 18)
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabelColor
        contentView.addSubview(versionLabel)

        // Author
        let authorLabel = NSTextField(labelWithString: "Powered by \(Constants.About.authorName)")
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
        let githubAttr = NSMutableAttributedString(string: "GitHub Repository")
        githubAttr.addAttributes([
            .link: Constants.About.githubURL,
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
        let donateAttr = NSMutableAttributedString(string: "Donate via PayPal")
        donateAttr.addAttributes([
            .link: Constants.About.donateURL,
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
        let copyrightLabel = NSTextField(
            labelWithString: "\u{00A9} \(Constants.About.copyrightYear) \(Constants.About.authorName). All Rights Reserved."
        )
        copyrightLabel.frame = NSRect(x: 0, y: 30, width: 300, height: 18)
        copyrightLabel.alignment = .center
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = .tertiaryLabelColor
        contentView.addSubview(copyrightLabel)

        newWindow.contentView = contentView
        NSApp.activate(ignoringOtherApps: true)
        newWindow.makeKeyAndOrderFront(nil)
        window = newWindow
    }
}
