import Cocoa

// MARK: - Test Runner

let testApp = NSApplication.shared
testApp.setActivationPolicy(.accessory)

print(String(repeating: "=", count: 60))
print("  Caffeinate Toggle — Unit Tests")
print(String(repeating: "=", count: 60))
print()

// MARK: - Helpers

func makeStatusBar() -> StatusBarController {
    return StatusBarController()
}

func makeManager() -> CaffeinateManager {
    return CaffeinateManager()
}

func cleanUpStatusBar(_ sb: StatusBarController) {
    NSStatusBar.system.removeStatusItem(sb.statusItem)
}

// ============================================================
// 1. CaffeinateManager — Initial State
// ============================================================

describe("CaffeinateManager: Initial State") {
    it("isActive is false on init") {
        let m = makeManager()
        try assertFalse(m.isActive)
    }

    it("process is nil on init") {
        let m = makeManager()
        try assertNil(m.process)
    }
}

// ============================================================
// 2. CaffeinateManager — Start
// ============================================================

describe("CaffeinateManager: Start") {
    it("sets isActive to true") {
        let m = makeManager()
        m.start()
        try assertTrue(m.isActive)
        m.stop()
    }

    it("sets process") {
        let m = makeManager()
        m.start()
        try assertNotNil(m.process)
        m.stop()
    }

    it("process is running") {
        let m = makeManager()
        m.start()
        try assertTrue(m.process!.isRunning)
        m.stop()
    }

    it("uses /usr/bin/caffeinate") {
        let m = makeManager()
        m.start()
        try assertEqual(m.process!.executableURL?.path, Constants.CaffeinateProcess.executablePath)
        m.stop()
    }

    it("uses -d argument") {
        let m = makeManager()
        m.start()
        try assertEqual(m.process!.arguments ?? [], Constants.CaffeinateProcess.arguments)
        m.stop()
    }

    it("does not start twice") {
        let m = makeManager()
        m.start()
        let firstProcess = m.process
        m.start()
        try assertTrue(m.process === firstProcess, "Should reuse same process")
        m.stop()
    }
}

// ============================================================
// 3. CaffeinateManager — Stop
// ============================================================

describe("CaffeinateManager: Stop") {
    it("sets isActive to false") {
        let m = makeManager()
        m.start()
        m.stop()
        try assertFalse(m.isActive)
    }

    it("clears process") {
        let m = makeManager()
        m.start()
        m.stop()
        try assertNil(m.process)
    }

    it("terminates the process") {
        let m = makeManager()
        m.start()
        let process = m.process!
        m.stop()
        usleep(100_000)
        try assertFalse(process.isRunning)
    }

    it("calling stop when already stopped does not crash") {
        let m = makeManager()
        m.stop()
        m.stop()
        try assertFalse(m.isActive)
        try assertNil(m.process)
    }
}

// ============================================================
// 4. CaffeinateManager — Toggle
// ============================================================

describe("CaffeinateManager: Toggle") {
    it("from inactive to active") {
        let m = makeManager()
        try assertFalse(m.isActive)
        m.toggle()
        try assertTrue(m.isActive)
        m.stop()
    }

    it("from active to inactive") {
        let m = makeManager()
        m.start()
        m.toggle()
        try assertFalse(m.isActive)
    }

    it("double toggle returns to inactive") {
        let m = makeManager()
        m.toggle()
        m.toggle()
        try assertFalse(m.isActive)
        try assertNil(m.process)
    }

    it("triple toggle ends active") {
        let m = makeManager()
        m.toggle()
        m.toggle()
        m.toggle()
        try assertTrue(m.isActive)
        try assertNotNil(m.process)
        m.stop()
    }
}

// ============================================================
// 5. CaffeinateManager — Delegate
// ============================================================

class TestDelegate: CaffeinateManagerDelegate {
    var startCount = 0
    var stopCount = 0
    var lastError: Error?

    func caffeinateManagerDidStart(_ manager: CaffeinateManager) { startCount += 1 }
    func caffeinateManagerDidStop(_ manager: CaffeinateManager) { stopCount += 1 }
    func caffeinateManager(_ manager: CaffeinateManager, didFailWithError error: Error) { lastError = error }
}

describe("CaffeinateManager: Delegate") {
    it("notifies delegate on start") {
        let m = makeManager()
        let d = TestDelegate()
        m.delegate = d
        m.start()
        try assertEqual(d.startCount, 1)
        m.stop()
    }

    it("notifies delegate on stop") {
        let m = makeManager()
        let d = TestDelegate()
        m.delegate = d
        m.start()
        m.stop()
        try assertEqual(d.stopCount, 1)
    }

    it("notifies start and stop on toggle cycle") {
        let m = makeManager()
        let d = TestDelegate()
        m.delegate = d
        m.toggle()
        try assertEqual(d.startCount, 1)
        m.toggle()
        try assertEqual(d.stopCount, 1)
    }
}

// ============================================================
// 6. CaffeinateManager — Unexpected Termination
// ============================================================

describe("CaffeinateManager: Unexpected Termination") {
    it("unexpected process exit notifies delegate on main queue") {
        let m = makeManager()
        let d = TestDelegate()
        m.delegate = d
        m.start()
        // Kill the process without going through stop() — simulates a crash
        m.process!.terminate()
        // Let the termination handler fire and its main-queue dispatch run
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
        try assertEqual(d.stopCount, 1, "Delegate should receive unexpected-stop notification")
        try assertFalse(m.isActive)
    }

    it("process reference is cleared on unexpected exit") {
        let m = makeManager()
        m.start()
        m.process!.terminate()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
        try assertNil(m.process)
    }
}

// ============================================================
// 8. Stress: Multiple Start/Stop Cycles
// ============================================================

describe("Stress: Multiple Start/Stop Cycles") {
    it("5 rapid start/stop cycles work correctly") {
        let m = makeManager()
        for i in 0..<5 {
            m.start()
            try assertTrue(m.isActive, "Cycle \(i): should be active after start")
            try assertNotNil(m.process, "Cycle \(i): process should exist")

            m.stop()
            try assertFalse(m.isActive, "Cycle \(i): should be inactive after stop")
            try assertNil(m.process, "Cycle \(i): process should be nil")
        }
    }
}

// ============================================================
// 9. IconRenderer
// ============================================================

describe("IconRenderer") {
    it("renders an 18x18 image") {
        let img = IconRenderer.render(isActive: false)
        try assertEqual(img.size.width, 18)
        try assertEqual(img.size.height, 18)
    }

    it("image is not a template (has colored dot)") {
        let img = IconRenderer.render(isActive: false)
        try assertFalse(img.isTemplate)
    }

    it("active and inactive icons differ") {
        let inactive = IconRenderer.render(isActive: false)
        let active = IconRenderer.render(isActive: true)
        try assertNotEqual(inactive.tiffRepresentation, active.tiffRepresentation, "Icons should differ between states")
    }
}

// ============================================================
// 10. StatusBarController — Menu Setup
// ============================================================

describe("StatusBarController: Menu Setup") {
    it("menu exists after init") {
        let sb = makeStatusBar()
        try assertNotNil(sb.statusItem.menu)
        cleanUpStatusBar(sb)
    }

    it("menu has 6 items (toggle, sep, settings, sep, about, quit)") {
        let sb = makeStatusBar()
        try assertEqual(sb.statusItem.menu!.items.count, 6)
        cleanUpStatusBar(sb)
    }

    it("first item is 'Turn On' with tag 1") {
        let sb = makeStatusBar()
        let item = sb.statusItem.menu!.items[0]
        try assertEqual(item.title, "Turn On")
        try assertEqual(item.tag, Constants.Menu.toggleTag)
        cleanUpStatusBar(sb)
    }

    it("second item is a separator") {
        let sb = makeStatusBar()
        try assertTrue(sb.statusItem.menu!.items[1].isSeparatorItem)
        cleanUpStatusBar(sb)
    }

    it("third item is 'Settings...'") {
        let sb = makeStatusBar()
        try assertEqual(sb.statusItem.menu!.items[2].title, Constants.Menu.settings)
        cleanUpStatusBar(sb)
    }

    it("fourth item is a separator") {
        let sb = makeStatusBar()
        try assertTrue(sb.statusItem.menu!.items[3].isSeparatorItem)
        cleanUpStatusBar(sb)
    }

    it("fifth item is 'About'") {
        let sb = makeStatusBar()
        try assertEqual(sb.statusItem.menu!.items[4].title, Constants.Menu.about)
        cleanUpStatusBar(sb)
    }

    it("sixth item is 'Quit'") {
        let sb = makeStatusBar()
        try assertEqual(sb.statusItem.menu!.items[5].title, Constants.Menu.quit)
        cleanUpStatusBar(sb)
    }

    it("no menu items have keyboard shortcuts") {
        let sb = makeStatusBar()
        for item in sb.statusItem.menu!.items where !item.isSeparatorItem {
            try assertEqual(item.keyEquivalent, "", "'\(item.title)' should have no shortcut")
        }
        cleanUpStatusBar(sb)
    }

    it("all non-separator items have StatusBarController as target") {
        let sb = makeStatusBar()
        for item in sb.statusItem.menu!.items where !item.isSeparatorItem {
            try assertTrue(item.target is StatusBarController, "'\(item.title)' target should be StatusBarController")
        }
        cleanUpStatusBar(sb)
    }
}

// ============================================================
// 11. StatusBarController — State Updates
// ============================================================

describe("StatusBarController: State Updates") {
    it("button has an image after init") {
        let sb = makeStatusBar()
        try assertNotNil(sb.statusItem.button?.image)
        cleanUpStatusBar(sb)
    }

    it("image size is 18x18") {
        let sb = makeStatusBar()
        let img = sb.statusItem.button?.image
        try assertEqual(img?.size.width, 18)
        try assertEqual(img?.size.height, 18)
        cleanUpStatusBar(sb)
    }

    it("updateState(isActive: true) changes toggle title to 'Turn Off'") {
        let sb = makeStatusBar()
        sb.updateState(isActive: true)
        let title = sb.statusItem.menu?.item(withTag: Constants.Menu.toggleTag)?.title
        try assertEqual(title, Constants.Menu.turnOff)
        cleanUpStatusBar(sb)
    }

    it("updateState(isActive: false) changes toggle title to 'Turn On'") {
        let sb = makeStatusBar()
        sb.updateState(isActive: true)
        sb.updateState(isActive: false)
        let title = sb.statusItem.menu?.item(withTag: Constants.Menu.toggleTag)?.title
        try assertEqual(title, Constants.Menu.turnOn)
        cleanUpStatusBar(sb)
    }

    it("icon changes between active and inactive states") {
        let sb = makeStatusBar()
        sb.updateState(isActive: false)
        let inactiveData = sb.statusItem.button?.image?.tiffRepresentation

        sb.updateState(isActive: true)
        let activeData = sb.statusItem.button?.image?.tiffRepresentation

        try assertNotEqual(inactiveData, activeData, "Icon should differ between states")
        cleanUpStatusBar(sb)
    }
}

// ============================================================
// 12. StatusBarController — Closure Callbacks
// ============================================================

describe("StatusBarController: Closures") {
    it("onToggle closure is called") {
        let sb = makeStatusBar()
        var called = false
        sb.onToggle = { called = true }
        _ = sb.statusItem.menu!.items[0].target!.perform(sb.statusItem.menu!.items[0].action)
        try assertTrue(called, "onToggle should have been called")
        cleanUpStatusBar(sb)
    }

    it("onSettings closure is called") {
        let sb = makeStatusBar()
        var called = false
        sb.onSettings = { called = true }
        _ = sb.statusItem.menu!.items[2].target!.perform(sb.statusItem.menu!.items[2].action)
        try assertTrue(called, "onSettings should have been called")
        cleanUpStatusBar(sb)
    }

    it("onAbout closure is called") {
        let sb = makeStatusBar()
        var called = false
        sb.onAbout = { called = true }
        _ = sb.statusItem.menu!.items[4].target!.perform(sb.statusItem.menu!.items[4].action)
        try assertTrue(called, "onAbout should have been called")
        cleanUpStatusBar(sb)
    }

    it("onQuit closure is called") {
        let sb = makeStatusBar()
        var called = false
        sb.onQuit = { called = true }
        _ = sb.statusItem.menu!.items[5].target!.perform(sb.statusItem.menu!.items[5].action)
        try assertTrue(called, "onQuit should have been called")
        cleanUpStatusBar(sb)
    }
}

// ============================================================
// 13. Constants
// ============================================================

describe("Constants") {
    it("icon size is 18x18") {
        try assertEqual(Constants.Icon.size.width, 18)
        try assertEqual(Constants.Icon.size.height, 18)
    }

    it("caffeinate executable path is /usr/bin/caffeinate") {
        try assertEqual(Constants.CaffeinateProcess.executablePath, "/usr/bin/caffeinate")
    }

    it("caffeinate arguments contain -d") {
        try assertEqual(Constants.CaffeinateProcess.arguments, ["-d"])
    }

    it("about window title is correct") {
        try assertEqual(Constants.About.windowTitle, "About Caffeinate Toggle")
    }

    it("toggle tag is 1") {
        try assertEqual(Constants.Menu.toggleTag, 1)
    }
}

// ============================================================
// 14. About Window
// ============================================================

describe("About Window") {
    it("creates a new window") {
        let countBefore = testApp.windows.count
        AboutWindowController.shared.show()
        try assertGreaterThan(testApp.windows.count, countBefore, "Should create a new window")
    }

    it("window has correct title") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }
        try assertNotNil(w, "Window should have title '\(Constants.About.windowTitle)'")
    }

    it("window is 300x340") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        try assertEqual(w.contentView?.frame.size.width, 300)
        try assertEqual(w.contentView?.frame.size.height, 340)
    }

    it("has 8 subviews (icon, name, version, author, github, donate, separator, copyright)") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        try assertEqual(w.contentView!.subviews.count, 8)
    }

    it("contains app name label") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue == "Caffeinate Toggle" }
        try assertTrue(found, "Should contain 'Caffeinate Toggle'")
    }

    it("contains author label") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue == "Powered by \(Constants.About.authorName)" }
        try assertTrue(found, "Should contain 'Powered by \(Constants.About.authorName)'")
    }

    it("contains 2026 copyright") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue.contains(Constants.About.copyrightYear) }
        try assertTrue(found, "Should contain '\(Constants.About.copyrightYear)' in copyright")
    }

    it("contains GitHub link") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.attributedStringValue.string.contains("GitHub") }
        try assertTrue(found, "Should contain GitHub link")
    }

    it("contains PayPal donate link") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.attributedStringValue.string.contains("PayPal") }
        try assertTrue(found, "Should contain PayPal donate link")
    }

    it("contains a separator") {
        AboutWindowController.shared.show()
        let w = testApp.windows.first { $0.title == Constants.About.windowTitle }!
        let boxes = w.contentView!.subviews.compactMap { $0 as? NSBox }
        let found = boxes.contains { $0.boxType == .separator }
        try assertTrue(found, "Should contain a separator")
    }

    it("singleton reuses same window") {
        AboutWindowController.shared.show()
        let countAfterFirst = testApp.windows.count
        AboutWindowController.shared.show()
        let countAfterSecond = testApp.windows.count
        try assertEqual(countAfterFirst, countAfterSecond, "Should not create additional windows")
    }
}

// ============================================================
// 15. AppDelegate Integration
// ============================================================

describe("AppDelegate: Integration") {
    it("applicationDidFinishLaunching sets up statusBar and manager") {
        let d = AppDelegate()
        d.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        try assertNotNil(d.statusBar)
        try assertNotNil(d.statusBar.statusItem.menu)
        try assertNotNil(d.statusBar.statusItem.button?.image)
        NSStatusBar.system.removeStatusItem(d.statusBar.statusItem)
    }

    it("applicationWillTerminate stops caffeinate") {
        let d = AppDelegate()
        d.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        d.userActivitySimulator.declareActivity = { }
        d.caffeinateManager.start()
        try assertTrue(d.caffeinateManager.isActive)
        d.applicationWillTerminate(Notification(name: NSApplication.willTerminateNotification))
        try assertFalse(d.caffeinateManager.isActive)
        NSStatusBar.system.removeStatusItem(d.statusBar.statusItem)
    }

    it("caffeinate start activates user activity simulator") {
        let d = AppDelegate()
        d.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        d.userActivitySimulator.declareActivity = { }
        try assertFalse(d.userActivitySimulator.isActive)
        d.caffeinateManager.start()
        try assertTrue(d.userActivitySimulator.isActive)
        d.caffeinateManager.stop()
        NSStatusBar.system.removeStatusItem(d.statusBar.statusItem)
    }

    it("caffeinate stop deactivates user activity simulator") {
        let d = AppDelegate()
        d.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        d.userActivitySimulator.declareActivity = { }
        d.caffeinateManager.start()
        d.caffeinateManager.stop()
        try assertFalse(d.userActivitySimulator.isActive)
        NSStatusBar.system.removeStatusItem(d.statusBar.statusItem)
    }
}

// ============================================================
// 16. UserActivitySimulator
// ============================================================

describe("UserActivitySimulator") {
    it("isActive is false on init") {
        let s = UserActivitySimulator()
        try assertFalse(s.isActive)
    }

    it("start sets isActive to true") {
        let s = UserActivitySimulator()
        s.declareActivity = { }
        s.start()
        try assertTrue(s.isActive)
        s.stop()
    }

    it("stop sets isActive to false") {
        let s = UserActivitySimulator()
        s.declareActivity = { }
        s.start()
        s.stop()
        try assertFalse(s.isActive)
    }

    it("start twice does not create duplicate timer") {
        let s = UserActivitySimulator()
        s.declareActivity = { }
        s.start()
        s.start()
        try assertTrue(s.isActive)
        s.stop()
        try assertFalse(s.isActive)
    }

    it("stop when already stopped does not crash") {
        let s = UserActivitySimulator()
        s.stop()
        s.stop()
        try assertFalse(s.isActive)
    }

    it("interval is 240 seconds") {
        try assertEqual(Constants.UserActivity.interval, 240)
    }

    it("stop after start leaves isActive false") {
        let s = UserActivitySimulator()
        s.declareActivity = { }
        s.start()
        s.stop()
        try assertFalse(s.isActive)
    }
}

// ============================================================
// 17. UserActivitySimulator — Branch Coverage
// ============================================================

describe("UserActivitySimulator: Branches") {
    it("fires declareActivity immediately on start") {
        let s = UserActivitySimulator()
        var fired = false
        s.declareActivity = { fired = true }
        s.start()
        try assertTrue(fired, "Should call declareActivity immediately on start")
        s.stop()
    }

    it("fires declareActivity exactly once on start (timer ticks not awaited)") {
        let s = UserActivitySimulator()
        var count = 0
        s.declareActivity = { count += 1 }
        s.start()
        try assertEqual(count, 1, "Should fire exactly once on start")
        s.stop()
    }

    it("start twice fires declareActivity only once") {
        let s = UserActivitySimulator()
        var count = 0
        s.declareActivity = { count += 1 }
        s.start()
        s.start()
        try assertEqual(count, 1, "Second start is no-op, declareActivity fires once")
        s.stop()
    }

    it("start then stop leaves isActive false") {
        let s = UserActivitySimulator()
        s.declareActivity = { }
        s.start()
        try assertTrue(s.isActive)
        s.stop()
        try assertFalse(s.isActive)
    }
}

// ============================================================
// 18. UserActivitySimulator — Default Closures
// ============================================================

describe("UserActivitySimulator: Default Closures") {
    it("default declareActivity runs without crashing") {
        let s = UserActivitySimulator()
        s.start()
        s.stop()
        try assertTrue(true)
    }
}

// ============================================================
// 19. SettingsController
// ============================================================

describe("SettingsController") {
    it("showSettings presents and dismisses modal without crashing") {
        // asyncAfter fires while runModal() is spinning its event loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { NSApp.abortModal() }
        SettingsController.showSettings()
        try assertTrue(true)
    }
}

// ============================================================
// Results
// ============================================================

printResults()

exit(totalFailed > 0 ? 1 : 0)
