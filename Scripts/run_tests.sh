#!/bin/bash
# Test runner for Caffeinate Toggle
# Run from project root: chmod +x Scripts/run_tests.sh && Scripts/run_tests.sh

set -e

# Resolve project root (parent of Scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

TMPDIR=$(mktemp -d)

echo "🧪 Compiling tests..."

# Swift requires top-level code to be in a file named main.swift.
# Concatenate TestFramework + tests into main.swift for compilation.
cat Tests/TestFramework.swift Tests/CaffeinateAppTests.swift > "$TMPDIR/main.swift"

# Compile all source files + test main
swiftc \
    Sources/Constants.swift \
    Sources/CaffeinateManager.swift \
    Sources/UserActivitySimulator.swift \
    Sources/IconRenderer.swift \
    Sources/StatusBarController.swift \
    Sources/AboutWindowController.swift \
    Sources/SettingsController.swift \
    Sources/AppDelegate.swift \
    "$TMPDIR/main.swift" \
    -o CaffeinateAppTests \
    -framework Cocoa

echo "🧪 Running tests..."
echo ""

./CaffeinateAppTests
EXIT_CODE=$?

# Cleanup
rm -f CaffeinateAppTests
rm -rf "$TMPDIR"

exit $EXIT_CODE
