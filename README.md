# Caffeinate Toggle

A lightweight macOS menu bar app that prevents your Mac from sleeping with a single click.

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## What it does

Caffeinate Toggle is a simple menu bar utility that wraps the built-in macOS `caffeinate` command. It lets you quickly toggle sleep prevention on or off without opening a terminal.

- Prevents display sleep when active (`caffeinate -d`)
- Lives entirely in the menu bar — no Dock icon, no windows
- Status indicator dot shows green (active) or red (inactive)
- Launch at startup option via Settings

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
chmod +x build.sh
./build.sh
```

Then move the app to your Applications folder:

```bash
mv "Caffeinate Toggle.app" /Applications/
```

### Launch

1. Open **Caffeinate Toggle** from `/Applications` (or double-click the `.app`)
2. A coffee cup icon will appear in your menu bar
3. Click the icon to toggle sleep prevention on/off

### Auto-start on login

Open **Settings** from the menu bar icon, then check **Launch at startup**.

Or manually: **System Settings > General > Login Items > add Caffeinate Toggle**

## Menu Options

| Option | Description |
|---|---|
| **Turn On / Turn Off** | Toggle the `caffeinate -d` process |
| **Settings...** | Configure launch at startup |
| **About** | App version, author info, and links |
| **Quit** | Stop caffeinate and exit the app |

## How it works

The app spawns `/usr/bin/caffeinate -d` as a child process to prevent display sleep. When toggled off (or when the app quits), it terminates that process. The menu bar icon shows a coffee cup with a small colored dot:

- **Green dot** — caffeinate is running, your Mac won't sleep
- **Red dot** — caffeinate is off, normal sleep behavior

## Project structure

```
CaffeinateApp/
  CaffeinateApp.swift   # Single-file Swift app (all logic)
  Info.plist             # App bundle metadata
  AppIcon.icns           # Application icon
  build.sh               # Build script (no Xcode required)
  media/                 # Source icon files (PNG, SVG, ICO)
  README.md
```

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode Command Line Tools (for building)

## Donate

If you find this app useful, consider buying me a coffee:

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue)](https://www.paypal.com/donate?business=victorsbraga@yahoo.com.br)

## Author

**Victor Braga**

- GitHub: [github.com/vsbraga](https://github.com/vsbraga)

## License

This project is open source. See the [repository](https://github.com/vsbraga/CaffeinateApp) for details.
