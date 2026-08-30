#!/bin/bash
# Build, install and open the keyboard Theme Lab in the Simulator.
#
#   ./ios/Tools/run-theme-lab.sh            # theme lab (fastest look at the renderer)
#   ./ios/Tools/run-theme-lab.sh normal     # the normal app, for enabling the real keyboard
#
# The lab is a DEBUG-only screen; it costs the shipping app nothing.
set -euo pipefail

cd "$(dirname "$0")/.."

MODE="${1:-lab}"
BUNDLE_ID="com.mochi.app"

# First booted simulator, or boot one if none is running.
DEVICE=$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; ids=[x["udid"] for v in d.values() for x in v]; print(ids[0] if ids else "")')
if [ -z "$DEVICE" ]; then
  DEVICE=$(xcrun simctl list devices available -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; ids=[x["udid"] for v in d.values() for x in v if "iPhone" in x["name"]]; print(ids[0] if ids else "")')
  [ -z "$DEVICE" ] && { echo "No iPhone simulator available."; exit 1; }
  xcrun simctl boot "$DEVICE"
fi

xcodegen generate >/dev/null

# `generic/platform=iOS Simulator` rather than a named device: xcodebuild on this machine does not
# enumerate specific simulators as destinations, only the placeholder.
xcodebuild -project Mochi.xcodeproj -scheme MochiApp \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug build \
  -quiet

APP=$(xcodebuild -project Mochi.xcodeproj -scheme MochiApp -showBuildSettings -configuration Debug 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR/ {d=$2} / FULL_PRODUCT_NAME/ {n=$2} END {print d"/"n}')
# showBuildSettings reports the device build dir; the simulator build lives beside it.
APP="${APP/Debug-iphoneos/Debug-iphonesimulator}"

open -a Simulator --args -CurrentDeviceUDID "$DEVICE"
xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$DEVICE" "$APP"

if [ "$MODE" = "normal" ]; then
  xcrun simctl launch "$DEVICE" "$BUNDLE_ID"
  echo
  echo "App launched. To test the REAL keyboard extension:"
  echo "  1. Simulator menu: I/O > Keyboard > Connect Hardware Keyboard  ->  OFF  (Cmd-Shift-K)"
  echo "  2. Settings > General > Keyboard > Keyboards > Add New Keyboard... > Mochi Keyboard"
  echo "  3. Open Safari/Notes, tap a text field, tap the globe key until Mochi appears."
else
  xcrun simctl launch "$DEVICE" "$BUNDLE_ID" -MochiThemeLab 1
  echo "Theme Lab launched. Tap ABC / 123 / #+= to switch planes; hold a key to see press feedback."
fi
