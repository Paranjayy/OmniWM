#!/bin/bash
set -e

# Change to the project directory
cd "$(dirname "$0")"

APP_NAME="OmniKey"
EXE_NAME="OmniKey"
APP_DIR="${APP_NAME}.app"

# Clean up
rm -rf "$APP_DIR"

# Compile
echo "🏗️ Compiling $APP_NAME..."
swiftc main.swift -o "$EXE_NAME" -framework Cocoa -framework CoreGraphics -framework Carbon

# Package as .app bundle
echo "📦 Packaging as .app..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Create Info.plist (essential for macOS Permissions)
cat <<EOF > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.omnikey.morpher</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

mv "$EXE_NAME" "$APP_DIR/Contents/MacOS/"

echo "✅ Success! Built $PWD/$APP_DIR"
echo "🚀 To launch: open $APP_DIR"
echo "--------------------------------------------------------"
echo "IMPORTANT: After launching, please add 'OmniKey' to your"
echo "Accessibility & Input Monitoring settings!"
echo "--------------------------------------------------------"
