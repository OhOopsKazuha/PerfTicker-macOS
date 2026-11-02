#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
cd "$(dirname "$0")/.."
[ -d dist/PerfTicker.app ] || { echo 'Build first: bash Source/build.sh' >&2; exit 1; }
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' dist/PerfTicker.app/Contents/Info.plist)"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/perfticker-package.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/PerfTicker-macOS"
/usr/bin/ditto dist/PerfTicker.app "$STAGE/PerfTicker-macOS/PerfTicker.app"
cp LICENSE NOTICE README.md README.en.md "$STAGE/PerfTicker-macOS/"
printf '%s\n' 'Complete corresponding source:' 'https://github.com/OhOopsKazuha/PerfTicker-macOS' "Release: v$VERSION" 'Download the matching source archive supplied with this release.' > "$STAGE/PerfTicker-macOS/SOURCE.txt"
/usr/bin/ditto -c -k --norsrc --keepParent "$STAGE/PerfTicker-macOS" "dist/PerfTicker-macOS-$VERSION-arm64.zip"
(cd dist && /usr/bin/shasum -a 256 "PerfTicker-macOS-$VERSION-arm64.zip" > SHA256SUMS.txt)
echo "Packaged dist/PerfTicker-macOS-$VERSION-arm64.zip"
