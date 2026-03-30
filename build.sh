#!/bin/bash
set -e

echo "Building PortsApp..."
swift build -c release 2>&1

BINARY=".build/release/PortsApp"
APP_DIR="PortsApp.app/Contents/MacOS"
PLIST_DIR="PortsApp.app/Contents"

mkdir -p "$APP_DIR"

cp "$BINARY" "$APP_DIR/PortsApp"

cat > "$PLIST_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>PortsApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.portsapp.PortsApp</string>
    <key>CFBundleName</key>
    <string>PortsApp</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF

echo ""
echo "Build complete! Run with:"
echo "  open PortsApp.app"
echo ""
echo "To install for launch at login, move to /Applications:"
echo "  cp -r PortsApp.app /Applications/"
