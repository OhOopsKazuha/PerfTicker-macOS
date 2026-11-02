#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
cd "$(dirname "$0")"
if [ -z "${DEVELOPER_DIR:-}" ]; then
  if [ -d /Library/Developer/CommandLineTools ]; then
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
  else
    export DEVELOPER_DIR="$(/usr/bin/xcode-select -p)"
  fi
fi
SDK="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"
APP="../dist/PerfTicker.app"
BUILD="$(mktemp -d "${TMPDIR:-/tmp}/perfticker-build.XXXXXX")"
trap 'rm -rf "$BUILD"' EXIT
mkdir -p "$BUILD" "$APP/Contents/MacOS" "$APP/Contents/Resources"
/usr/bin/xcrun clang -O2 -arch arm64 -isysroot "$SDK" -mmacosx-version-min=13.0 -c Probe.c -o "$BUILD/Probe.o"
/usr/bin/xcrun swiftc -O -swift-version 5 -target arm64-apple-macosx13.0 -sdk "$SDK" -import-objc-header Probe.h main.swift "$BUILD/Probe.o" -framework AppKit -framework WebKit -framework IOKit -o "$APP/Contents/MacOS/PerfTicker"
cp Resources/index.html "$APP/Contents/Resources/"
if [ -f Resources/AppIcon.icns ]; then cp Resources/AppIcon.icns "$APP/Contents/Resources/"; fi
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleExecutable</key><string>PerfTicker</string><key>CFBundleIdentifier</key><string>local.perfticker.mac</string><key>CFBundleName</key><string>PerfTicker</string><key>CFBundleDisplayName</key><string>性能行情终端</string><key>CFBundleVersion</key><string>1</string><key>CFBundleShortVersionString</key><string>0.1.0</string><key>CFBundlePackageType</key><string>APPL</string><key>CFBundleIconFile</key><string>AppIcon</string><key>LSMinimumSystemVersion</key><string>13.0</string><key>NSHighResolutionCapable</key><true/><key>NSSupportsAutomaticGraphicsSwitching</key><true/></dict></plist>
PLIST
/usr/bin/codesign --force --deep --sign - "$APP"
echo "Built $APP"
