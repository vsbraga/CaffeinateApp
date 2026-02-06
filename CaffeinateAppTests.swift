import Cocoa

// MARK: - Minimal Test Framework

var totalTests = 0
var totalPassed = 0
var totalFailed = 0
var failedTests: [String] = []
var currentSuite = ""

func describe(_ name: String, _ block: () -> Void) {
    currentSuite = name
    print("--- \(name) ---")
    block()
    print()
}

func it(_ name: String, _ block: () -> Void) {
    totalTests += 1
    do {
        block()
        totalPassed += 1
        print("  PASS  \(name)")
    } catch {
        totalFailed += 1
        failedTests.append("\(currentSuite) > \(name)")
        print("  FAIL  \(name)")
    }
}

struct AssertionError: Error {
    let message: String
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "") {
    if a != b {
        let detail = msg.isEmpty ? "Expected \(b), got \(a)" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

func assertTrue(_ value: Bool, _ msg: String = "") {
    if !value {
        let detail = msg.isEmpty ? "Expected true, got false" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

func assertFalse(_ value: Bool, _ msg: String = "") {
    assertTrue(!value, msg.isEmpty ? "Expected false, got true" : msg)
}

func assertNil<T>(_ value: T?, _ msg: String = "") {
    if value != nil {
        let detail = msg.isEmpty ? "Expected nil" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

func assertNotNil<T>(_ value: T?, _ msg: String = "") {
    if value == nil {
        let detail = msg.isEmpty ? "Expected non-nil" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

func assertGreaterThan<T: Comparable>(_ a: T, _ b: T, _ msg: String = "") {
    if a <= b {
        let detail = msg.isEmpty ? "Expected \(a) > \(b)" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

func assertNotEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "") {
    if a == b {
        let detail = msg.isEmpty ? "Expected values to differ" : msg
        print("         -> \(detail)")
        totalFailed += 1
        totalPassed -= 1
        failedTests.append("\(currentSuite) > \(detail)")
    }
}

// MARK: - Helper

func makeDelegate() -> AppDelegate {
    let d = AppDelegate()
    d.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    d.setupMenu()
    d.updateIcon()
    return d
}

func cleanUp(_ d: AppDelegate) {
    d.stopCaffeinate()
    NSStatusBar.system.removeStatusItem(d.statusItem)
}

// MARK: - Test Runner

let testApp = NSApplication.shared
testApp.setActivationPolicy(.accessory)

print(String(repeating: "=", count: 60))
print("  Caffeinate Toggle — Unit Tests")
print(String(repeating: "=", count: 60))
print()

// ============================================================
// 1. Initial State
// ============================================================

describe("Initial State") {
    it("isActive is false on init") {
        let d = AppDelegate()
        assertFalse(d.isActive)
    }

    it("caffeinateProcess is nil on init") {
        let d = AppDelegate()
        assertNil(d.caffeinateProcess)
    }

    it("statusItem is nil before launch") {
        let d = AppDelegate()
        assertNil(d.statusItem)
    }
}

// ============================================================
// 2. Menu Setup
// ============================================================

describe("Menu Setup") {
    it("menu exists after setupMenu") {
        let d = makeDelegate()
        assertNotNil(d.statusItem.menu)
        cleanUp(d)
    }

    it("menu has 6 items (toggle, sep, settings, sep, about, quit)") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items.count, 6)
        cleanUp(d)
    }

    it("first item is 'Turn On' with tag 1") {
        let d = makeDelegate()
        let item = d.statusItem.menu!.items[0]
        assertEqual(item.title, "Turn On")
        assertEqual(item.tag, 1)
        cleanUp(d)
    }

    it("second item is a separator") {
        let d = makeDelegate()
        assertTrue(d.statusItem.menu!.items[1].isSeparatorItem)
        cleanUp(d)
    }

    it("third item is 'Settings...'") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[2].title, "Settings...")
        cleanUp(d)
    }

    it("fourth item is a separator") {
        let d = makeDelegate()
        assertTrue(d.statusItem.menu!.items[3].isSeparatorItem)
        cleanUp(d)
    }

    it("fifth item is 'About'") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[4].title, "About")
        cleanUp(d)
    }

    it("sixth item is 'Quit'") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[5].title, "Quit")
        cleanUp(d)
    }

    it("no menu items have keyboard shortcuts") {
        let d = makeDelegate()
        for item in d.statusItem.menu!.items where !item.isSeparatorItem {
            assertEqual(item.keyEquivalent, "", "'\(item.title)' should have no shortcut")
        }
        cleanUp(d)
    }

    it("all non-separator items have AppDelegate as target") {
        let d = makeDelegate()
        for item in d.statusItem.menu!.items where !item.isSeparatorItem {
            assertTrue(item.target is AppDelegate, "'\(item.title)' target should be AppDelegate")
        }
        cleanUp(d)
    }

    it("toggle item action is toggleCaffeinate") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[0].action, #selector(AppDelegate.toggleCaffeinate))
        cleanUp(d)
    }

    it("settings item action is openSettings") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[2].action, #selector(AppDelegate.openSettings))
        cleanUp(d)
    }

    it("about item action is showAbout") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[4].action, #selector(AppDelegate.showAbout))
        cleanUp(d)
    }

    it("quit item action is quitApp") {
        let d = makeDelegate()
        assertEqual(d.statusItem.menu!.items[5].action, #selector(AppDelegate.quitApp))
        cleanUp(d)
    }
}

// ============================================================
// 3. Start Caffeinate
// ============================================================

describe("Start Caffeinate") {
    it("sets isActive to true") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertTrue(d.isActive)
        cleanUp(d)
    }

    it("sets caffeinateProcess") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertNotNil(d.caffeinateProcess)
        cleanUp(d)
    }

    it("process is running") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertTrue(d.caffeinateProcess!.isRunning)
        cleanUp(d)
    }

    it("uses /usr/bin/caffeinate") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertEqual(d.caffeinateProcess!.executableURL?.path, "/usr/bin/caffeinate")
        cleanUp(d)
    }

    it("uses -d argument") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertEqual(d.caffeinateProcess!.arguments ?? [], ["-d"])
        cleanUp(d)
    }

    it("menu title changes to 'Turn Off'") {
        let d = makeDelegate()
        d.startCaffeinate()
        let title = d.statusItem.menu?.item(withTag: 1)?.title
        assertEqual(title, "Turn Off")
        cleanUp(d)
    }
}

// ============================================================
// 4. Stop Caffeinate
// ============================================================

describe("Stop Caffeinate") {
    it("sets isActive to false") {
        let d = makeDelegate()
        d.startCaffeinate()
        d.stopCaffeinate()
        assertFalse(d.isActive)
        cleanUp(d)
    }

    it("clears caffeinateProcess") {
        let d = makeDelegate()
        d.startCaffeinate()
        d.stopCaffeinate()
        assertNil(d.caffeinateProcess)
        cleanUp(d)
    }

    it("terminates the process") {
        let d = makeDelegate()
        d.startCaffeinate()
        let process = d.caffeinateProcess!
        d.stopCaffeinate()
        usleep(100_000)
        assertFalse(process.isRunning)
        cleanUp(d)
    }

    it("menu title changes to 'Turn On'") {
        let d = makeDelegate()
        d.startCaffeinate()
        d.stopCaffeinate()
        let title = d.statusItem.menu?.item(withTag: 1)?.title
        assertEqual(title, "Turn On")
        cleanUp(d)
    }

    it("calling stop when already stopped does not crash") {
        let d = makeDelegate()
        d.stopCaffeinate()
        d.stopCaffeinate()
        assertFalse(d.isActive)
        assertNil(d.caffeinateProcess)
        cleanUp(d)
    }
}

// ============================================================
// 5. Toggle
// ============================================================

describe("Toggle Caffeinate") {
    it("from inactive to active") {
        let d = makeDelegate()
        assertFalse(d.isActive)
        d.toggleCaffeinate()
        assertTrue(d.isActive)
        cleanUp(d)
    }

    it("from active to inactive") {
        let d = makeDelegate()
        d.startCaffeinate()
        d.toggleCaffeinate()
        assertFalse(d.isActive)
        cleanUp(d)
    }

    it("double toggle returns to inactive") {
        let d = makeDelegate()
        d.toggleCaffeinate()
        d.toggleCaffeinate()
        assertFalse(d.isActive)
        assertNil(d.caffeinateProcess)
        cleanUp(d)
    }

    it("triple toggle ends active") {
        let d = makeDelegate()
        d.toggleCaffeinate()
        d.toggleCaffeinate()
        d.toggleCaffeinate()
        assertTrue(d.isActive)
        assertNotNil(d.caffeinateProcess)
        cleanUp(d)
    }
}

// ============================================================
// 6. Icon
// ============================================================

describe("Icon") {
    it("button has an image after updateIcon") {
        let d = makeDelegate()
        d.updateIcon()
        assertNotNil(d.statusItem.button?.image)
        cleanUp(d)
    }

    it("image size is 18x18") {
        let d = makeDelegate()
        d.updateIcon()
        let img = d.statusItem.button?.image
        assertEqual(img?.size.width, 18)
        assertEqual(img?.size.height, 18)
        cleanUp(d)
    }

    it("image is not a template (has colored dot)") {
        let d = makeDelegate()
        d.updateIcon()
        assertFalse(d.statusItem.button!.image!.isTemplate)
        cleanUp(d)
    }

    it("icon changes between active and inactive states") {
        let d = makeDelegate()
        d.updateIcon()
        let inactiveData = d.statusItem.button?.image?.tiffRepresentation

        d.startCaffeinate()
        let activeData = d.statusItem.button?.image?.tiffRepresentation

        assertNotEqual(inactiveData, activeData, "Icon should differ between states")
        cleanUp(d)
    }
}

// ============================================================
// 7. Application Lifecycle
// ============================================================

describe("Application Lifecycle") {
    it("applicationWillTerminate stops caffeinate") {
        let d = makeDelegate()
        d.startCaffeinate()
        assertTrue(d.isActive)

        d.applicationWillTerminate(Notification(name: NSApplication.willTerminateNotification))

        assertFalse(d.isActive)
        assertNil(d.caffeinateProcess)
        cleanUp(d)
    }

    it("applicationDidFinishLaunching sets up everything") {
        let d = AppDelegate()
        d.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))

        assertNotNil(d.statusItem)
        assertNotNil(d.statusItem.menu)
        assertNotNil(d.statusItem.button?.image)
        cleanUp(d)
    }
}

// ============================================================
// 8. Multiple Start/Stop Cycles
// ============================================================

describe("Stress: Multiple Start/Stop Cycles") {
    it("5 rapid start/stop cycles work correctly") {
        let d = makeDelegate()
        for i in 0..<5 {
            d.startCaffeinate()
            assertTrue(d.isActive, "Cycle \(i): should be active after start")
            assertNotNil(d.caffeinateProcess, "Cycle \(i): process should exist")

            d.stopCaffeinate()
            assertFalse(d.isActive, "Cycle \(i): should be inactive after stop")
            assertNil(d.caffeinateProcess, "Cycle \(i): process should be nil")
        }
        cleanUp(d)
    }
}

// ============================================================
// 9. About Window
// ============================================================

describe("About Window") {
    it("creates a new window") {
        let d = makeDelegate()
        let countBefore = testApp.windows.count
        d.showAbout()
        assertGreaterThan(testApp.windows.count, countBefore, "Should create a new window")
        cleanUp(d)
    }

    it("window has correct title") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }
        assertNotNil(w, "Window should have title 'About Caffeinate Toggle'")
        cleanUp(d)
    }

    it("window is 300x340") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        assertEqual(w.contentView?.frame.size.width, 300)
        assertEqual(w.contentView?.frame.size.height, 340)
        cleanUp(d)
    }

    it("has 8 subviews (icon, name, version, author, github, donate, separator, copyright)") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        assertEqual(w.contentView!.subviews.count, 8)
        cleanUp(d)
    }

    it("contains app name label") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue == "Caffeinate Toggle" }
        assertTrue(found, "Should contain 'Caffeinate Toggle'")
        cleanUp(d)
    }

    it("contains version label") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue == "Version 1.0" }
        assertTrue(found, "Should contain 'Version 1.0'")
        cleanUp(d)
    }

    it("contains author label") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue == "Powered by Victor Braga" }
        assertTrue(found, "Should contain 'Powered by Victor Braga'")
        cleanUp(d)
    }

    it("contains 2026 copyright") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.stringValue.contains("2026") }
        assertTrue(found, "Should contain '2026' in copyright")
        cleanUp(d)
    }

    it("contains GitHub link") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.attributedStringValue.string.contains("GitHub") }
        assertTrue(found, "Should contain GitHub link")
        cleanUp(d)
    }

    it("contains PayPal donate link") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let labels = w.contentView!.subviews.compactMap { $0 as? NSTextField }
        let found = labels.contains { $0.attributedStringValue.string.contains("PayPal") }
        assertTrue(found, "Should contain PayPal donate link")
        cleanUp(d)
    }

    it("contains a separator") {
        let d = makeDelegate()
        d.showAbout()
        let w = testApp.windows.first { $0.title == "About Caffeinate Toggle" }!
        let boxes = w.contentView!.subviews.compactMap { $0 as? NSBox }
        let found = boxes.contains { $0.boxType == .separator }
        assertTrue(found, "Should contain a separator")
        cleanUp(d)
    }
}

// ============================================================
// Results
// ============================================================

print(String(repeating: "=", count: 60))
if totalFailed == 0 {
    print("  ✅ All \(totalTests) tests passed!")
} else {
    print("  ❌ \(totalPassed)/\(totalTests) passed, \(totalFailed) failed")
    print()
    for name in failedTests {
        print("  FAILED: \(name)")
    }
}
print(String(repeating: "=", count: 60))

exit(totalFailed > 0 ? 1 : 0)
