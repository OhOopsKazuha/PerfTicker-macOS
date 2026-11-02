#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
cd "$(dirname "$0")/.."
APP=dist/PerfTicker.app
[ -x "$APP/Contents/MacOS/PerfTicker" ] || { echo 'Build first: bash Source/build.sh' >&2; exit 1; }
/usr/bin/codesign --verify --deep --strict "$APP"
/usr/bin/plutil -lint "$APP/Contents/Info.plist"
/usr/bin/file "$APP/Contents/MacOS/PerfTicker" | /usr/bin/grep -q arm64
SAMPLE="$(mktemp "${TMPDIR:-/tmp}/perfticker-sample.XXXXXX")"
trap 'rm -f "$SAMPLE"' EXIT
"$APP/Contents/MacOS/PerfTicker" --self-test > "$SAMPLE"
python3 - "$SAMPLE" <<'PY'
import json,math,sys
s=json.load(open(sys.argv[1]))
assert s['cores'] and all(math.isfinite(x) and 0<=x<=100 for x in s['cores'])
assert 0<=s['cpu']<=100 and 0<=s['mem']<=100
assert s['memTotal']>0 and 0<=s['memUsed']<=s['memTotal']
assert isinstance(s['processes'],list) and len(s['processes'])>0
assert all(0<=p['cpu']<=100 and p['mem']>=0 for p in s['processes'])
assert all(math.isfinite(s[k]) and s[k]>=0 for k in ['rx','tx','diskRead','diskWrite'])
assert 'gpu' not in s or 0<=s['gpu']<=100
print('PASS: ARM64 app, signature, bundle metadata and live sampling bounds.')
print('Process names and raw samples are intentionally omitted from logs.')
PY
