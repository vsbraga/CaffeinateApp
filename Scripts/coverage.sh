#!/bin/bash
# Code coverage report for Caffeinate Toggle
# Run from project root: chmod +x Scripts/coverage.sh && Scripts/coverage.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

TMPDIR=$(mktemp -d)
PROFRAW="$TMPDIR/coverage.profraw"
PROFDATA="$TMPDIR/coverage.profdata"
BINARY="$TMPDIR/CaffeinateAppCov"

cat Tests/TestFramework.swift Tests/CaffeinateAppTests.swift > "$TMPDIR/main.swift"

echo "🔍 Compiling with coverage instrumentation..."
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
    -profile-generate \
    -profile-coverage-mapping \
    -o "$BINARY" \
    -framework Cocoa

echo "🔍 Running tests..."
echo ""
LLVM_PROFILE_FILE="$PROFRAW" "$BINARY"

echo ""
xcrun llvm-profdata merge -sparse "$PROFRAW" -o "$PROFDATA"

echo "📊 Coverage Report"
echo ""
xcrun llvm-cov report "$BINARY" \
    -instr-profile="$PROFDATA" \
    Sources/AppDelegate.swift \
    Sources/CaffeinateManager.swift \
    Sources/Constants.swift \
    Sources/IconRenderer.swift \
    Sources/SettingsController.swift \
    Sources/StatusBarController.swift \
    Sources/AboutWindowController.swift \
    Sources/UserActivitySimulator.swift

echo ""
echo "📋 Uncovered lines per file"
echo ""
for f in Sources/AppDelegate.swift Sources/CaffeinateManager.swift Sources/UserActivitySimulator.swift Sources/StatusBarController.swift Sources/SettingsController.swift; do
    echo "── $f"
    xcrun llvm-cov show "$BINARY" \
        -instr-profile="$PROFDATA" \
        -format=text \
        -show-line-counts \
        "$f" 2>/dev/null | grep -E "^\s+0\|" | head -20 || echo "   (none)"
    echo ""
done

rm -rf "$TMPDIR"
