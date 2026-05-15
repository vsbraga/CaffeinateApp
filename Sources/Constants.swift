import Cocoa

enum Constants {

    // MARK: - Icon

    enum Icon {
        static let size = NSSize(width: 18, height: 18)
        static let lineWidth: CGFloat = 1.2
        static let steamLineWidth: CGFloat = 0.9
        static let steamAlpha: CGFloat = 0.8

        // Cup body
        static let cupRect = NSRect(x: 1, y: 3, width: 9, height: 10)
        static let cupCornerRadius: CGFloat = 1.5

        // Handle
        static let handleCenter = NSPoint(x: 10, y: 9)
        static let handleRadius: CGFloat = 2.5
        static let handleStartAngle: CGFloat = -60
        static let handleEndAngle: CGFloat = 60

        // Steam lines
        static let steam1Start = NSPoint(x: 4, y: 13.5)
        static let steam1End = NSPoint(x: 4, y: 17)
        static let steam1CP1 = NSPoint(x: 2.5, y: 15)
        static let steam1CP2 = NSPoint(x: 5.5, y: 15.5)

        static let steam2Start = NSPoint(x: 7.5, y: 13.5)
        static let steam2End = NSPoint(x: 7.5, y: 17)
        static let steam2CP1 = NSPoint(x: 6, y: 15)
        static let steam2CP2 = NSPoint(x: 9, y: 15.5)

        // Status dot
        static let dotSize: CGFloat = 5.0
        static let dotOrigin = NSPoint(x: 13, y: 0)

        static let activeColor = NSColor(red: 0.15, green: 0.82, blue: 0.26, alpha: 1.0)
        static let inactiveColor = NSColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0)
    }

    // MARK: - Process

    enum CaffeinateProcess {
        static let executablePath = "/usr/bin/caffeinate"
        static let arguments = ["-d"]
    }

    // MARK: - About Window

    enum About {
        static let windowSize = NSRect(x: 0, y: 0, width: 300, height: 340)
        static let windowTitle = "About Caffeinate Toggle"
        static let githubURL = "https://github.com/vsbraga/CaffeinateApp"
        static let donateURL = "https://www.paypal.com/donate?business=victorsbraga@yahoo.com.br"
        static let copyrightYear = "2026"
        static let authorName = "Victor Braga"
    }

    // MARK: - User Activity (Teams keep-alive)

    enum UserActivity {
        // Fire every 4 minutes — under Teams' 5-minute idle threshold
        static let interval: TimeInterval = 240
    }

    // MARK: - Menu

    enum Menu {
        static let turnOn = "Turn On"
        static let turnOff = "Turn Off"
        static let settings = "Settings..."
        static let about = "About"
        static let quit = "Quit"
        static let toggleTag = 1
    }
}
