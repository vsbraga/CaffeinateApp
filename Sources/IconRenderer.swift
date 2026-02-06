import Cocoa

enum IconRenderer {

    static func render(isActive: Bool) -> NSImage {
        let icon = NSImage(size: Constants.Icon.size, flipped: false) { _ in
            let fgColor = NSColor(named: "labelColor") ?? NSColor.white
            fgColor.setStroke()

            // Cup body
            let cupBody = NSBezierPath(
                roundedRect: Constants.Icon.cupRect,
                xRadius: Constants.Icon.cupCornerRadius,
                yRadius: Constants.Icon.cupCornerRadius
            )
            cupBody.lineWidth = Constants.Icon.lineWidth
            cupBody.stroke()

            // Cup handle
            let handle = NSBezierPath()
            handle.lineWidth = Constants.Icon.lineWidth
            handle.appendArc(
                withCenter: Constants.Icon.handleCenter,
                radius: Constants.Icon.handleRadius,
                startAngle: Constants.Icon.handleStartAngle,
                endAngle: Constants.Icon.handleEndAngle,
                clockwise: false
            )
            handle.stroke()

            // Steam
            fgColor.withAlphaComponent(Constants.Icon.steamAlpha).setStroke()

            let steam1 = NSBezierPath()
            steam1.lineWidth = Constants.Icon.steamLineWidth
            steam1.move(to: Constants.Icon.steam1Start)
            steam1.curve(
                to: Constants.Icon.steam1End,
                controlPoint1: Constants.Icon.steam1CP1,
                controlPoint2: Constants.Icon.steam1CP2
            )
            steam1.stroke()

            let steam2 = NSBezierPath()
            steam2.lineWidth = Constants.Icon.steamLineWidth
            steam2.move(to: Constants.Icon.steam2Start)
            steam2.curve(
                to: Constants.Icon.steam2End,
                controlPoint1: Constants.Icon.steam2CP1,
                controlPoint2: Constants.Icon.steam2CP2
            )
            steam2.stroke()

            // Status indicator dot
            let dotRect = NSRect(
                origin: Constants.Icon.dotOrigin,
                size: NSSize(width: Constants.Icon.dotSize, height: Constants.Icon.dotSize)
            )
            let statusColor = isActive ? Constants.Icon.activeColor : Constants.Icon.inactiveColor
            statusColor.setFill()
            NSBezierPath(ovalIn: dotRect).fill()

            return true
        }
        icon.isTemplate = false
        return icon
    }
}
