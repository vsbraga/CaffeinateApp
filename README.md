# Caffeinate Toggle

A lightweight macOS menu bar app that prevents your Mac from sleeping with a single click.

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-GPL%20v3-green)
![Version](https://img.shields.io/badge/version-1.1-brightgreen)

## What it does

Caffeinate Toggle is a simple menu bar utility that wraps the built-in macOS `caffeinate` command. It lets you quickly toggle sleep prevention on or off without opening a terminal.

- Prevents display sleep when active (`caffeinate -d`)
- Keeps MS Teams (and similar apps) status **Available** — never goes Away or Offline
- Lives entirely in the menu bar — no Dock icon, no windows
- Status indicator dot shows green (active) or red (inactive)
- Launch at startup option via Settings

### Teams keep-alive

When the toggle is on, the app posts a synthetic mouse-moved `CGEvent` at the current cursor position every 4 minutes. This resets `HIDIdleTime` — the IOKit idle counter that Teams/Electron reads to detect inactivity — keeping your status Available without visibly moving the cursor.

> **Accessibility permission required.** On first use, the app will prompt you to grant access under **System Settings › Privacy & Security › Accessibility**. This is required because `CGEventPost` is the only reliable way to reset `HIDIdleTime`. The prompt appears at most once per app session.

## Screenshots

| Menu Bar Icon | Context Menu |
|---|---|
| Coffee cup with status dot | Turn On/Off, Settings, About, Quit |

## Installation

### Build from source

Requires macOS 12.0+ and Xcode Command Line Tools.

```bash
git clone https://github.com/vsbraga/CaffeinateApp.git
cd CaffeinateApp
chmod +x Scripts/build.sh
Scripts/build.sh
```

Then move the app to your Applications folder:

```bash
cp -r "Caffeinate Toggle.app" /Applications/
open /Applications/Caffeinate\ Toggle.app
```

### Auto-start on login

Open **Settings** from the menu bar icon, then check **Launch at startup**.

Or manually: **System Settings > General > Login Items > add Caffeinate Toggle**

## Menu Options

| Option | Description |
|---|---|
| **Turn On / Turn Off** | Toggle sleep prevention and Teams keep-alive |
| **Settings...** | Configure launch at startup |
| **About** | App version, author info, and links |
| **Quit** | Stop caffeinate and exit the app |

## How it works

When toggled on, the app does two things:

1. Spawns `/usr/bin/caffeinate -d` to prevent display sleep.
2. Starts a timer that posts a `CGEvent` of type `mouseMoved` at the current cursor position every 4 minutes. This resets `HIDIdleTime` in IOKit — the counter Teams/Electron reads via `IOHIDSystem` to detect user inactivity. The cursor does not visibly move.

Both are stopped when you toggle off or quit the app. The menu bar icon shows a coffee cup with a small colored dot:

- **Green dot** — active: display sleep blocked, Teams kept Available
- **Red dot** — inactive: normal sleep and presence behavior

### Why not `caffeinate -u`?

`caffeinate -u` calls `IOPMAssertionDeclareUserActivity`, which only affects the power management sleep timer. Teams reads `HIDIdleTime` directly via IOKit, which is only reset by actual input events — hence the `CGEvent` approach.

## Project structure

```
CaffeinateApp/
  Sources/
    main.swift                  # App entry point
    AppDelegate.swift           # App coordinator
    Constants.swift             # Centralized constants
    CaffeinateManager.swift     # Caffeinate process lifecycle
    UserActivitySimulator.swift # Teams keep-alive (CGEvent every 4 min)
    IconRenderer.swift          # Menu bar icon drawing
    StatusBarController.swift   # Status item and menu
    AboutWindowController.swift # About dialog
    SettingsController.swift    # Settings dialog
  Tests/
    TestFramework.swift         # Lightweight test framework
    CaffeinateAppTests.swift    # Unit tests (81 tests, 93.93% line coverage)
  Resources/
    Info.plist                  # App bundle metadata
    AppIcon.icns                # Application icon
  Scripts/
    build.sh                    # Build script (no Xcode required)
    run_tests.sh                # Test runner
    coverage.sh                 # LLVM line/function/region coverage report
  media/                        # Source icon files (PNG, SVG, ICO)
  README.md
  LICENSE
```

## Running tests

```bash
chmod +x Scripts/run_tests.sh
Scripts/run_tests.sh
```

## Code coverage

```bash
chmod +x Scripts/coverage.sh
Scripts/coverage.sh
```

Generates a per-file line/function/region report using LLVM instrumentation. Current coverage: **93.93% lines** across all source files.

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode Command Line Tools (for building)
- Accessibility permission (for Teams keep-alive — prompted on first use)

## Donate

If you find this app useful, consider buying me a coffee:

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue)](https://www.paypal.com/donate?business=victorsbraga@yahoo.com.br)

## Author

**Victor Braga**

- GitHub: [github.com/vsbraga](https://github.com/vsbraga)

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
