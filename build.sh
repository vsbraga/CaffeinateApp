#!/bin/bash
# Build script for Caffeinate Toggle menu bar app
# Run this on your Mac: chmod +x build.sh && ./build.sh

set -e

echo "🔨 Building Caffeinate Toggle..."

# Clean previous build
rm -rf "Caffeinate Toggle.app"

# Generate app icon if .icns is missing
if [ ! -f AppIcon.icns ]; then
    echo "🖼  Generating AppIcon.icns from media/CaffeinateIcon.png..."
    SRC="media/CaffeinateIcon.png"
    DEST="AppIcon.iconset"
    mkdir -p "$DEST"
    sips -z 16 16     "$SRC" --out "$DEST/icon_16x16.png"      > /dev/null
    sips -z 32 32     "$SRC" --out "$DEST/icon_16x16@2x.png"   > /dev/null
    sips -z 32 32     "$SRC" --out "$DEST/icon_32x32.png"      > /dev/null
    sips -z 64 64     "$SRC" --out "$DEST/icon_32x32@2x.png"   > /dev/null
    sips -z 128 128   "$SRC" --out "$DEST/icon_128x128.png"    > /dev/null
    sips -z 256 256   "$SRC" --out "$DEST/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   "$SRC" --out "$DEST/icon_256x256.png"    > /dev/null
    sips -z 512 512   "$SRC" --out "$DEST/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   "$SRC" --out "$DEST/icon_512x512.png"    > /dev/null
    sips -z 1024 1024 "$SRC" --out "$DEST/icon_512x512@2x.png" > /dev/null
    iconutil -c icns "$DEST" -o AppIcon.icns
    rm -rf "$DEST"
fi

# Create app bundle structure
mkdir -p "Caffeinate Toggle.app/Contents/MacOS"
mkdir -p "Caffeinate Toggle.app/Contents/Resources"

# Compile Swift source
swiftc CaffeinateApp.swift main.swift \
    -o "Caffeinate Toggle.app/Contents/MacOS/CaffeinateApp" \
    -framework Cocoa \
    -O

# Copy Info.plist and app icon
cp Info.plist "Caffeinate Toggle.app/Contents/"
cp AppIcon.icns "Caffeinate Toggle.app/Contents/Resources/"

echo ""
echo "✅ Build successful!"
echo ""
echo "Your app is ready: Caffeinate Toggle.app"
echo ""
echo "To install:"
echo "  1. Move 'Caffeinate Toggle.app' to /Applications"
echo "  2. Double-click to launch"
echo "  3. A coffee cup icon will appear in your menu bar"
echo ""
echo "To auto-start on login:"
echo "  System Settings → General → Login Items → add 'Caffeinate Toggle'"
