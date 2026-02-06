#!/bin/bash
# Test runner for Caffeinate Toggle
# Usage: chmod +x run_tests.sh && ./run_tests.sh

set -e

TMPDIR=$(mktemp -d)

echo "🧪 Compiling tests..."

# Swift requires top-level code to be in a file named main.swift.
# Copy the test runner as main.swift for compilation.
cp CaffeinateAppTests.swift "$TMPDIR/main.swift"

swiftc \
    CaffeinateApp.swift \
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
