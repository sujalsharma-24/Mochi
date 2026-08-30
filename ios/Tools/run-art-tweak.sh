#!/bin/bash
# Build, install and open the per-key illustration placement lab.
#
#   ./ios/Tools/run-art-tweak.sh                        # Fantasy Castle Night
#   ./ios/Tools/run-art-tweak.sh cozy-sakura-cafe       # any built-in theme, by id suffix
#
# In the lab: tap a key to select its illustration, drag X / Y / Size / Opacity, then press
# **Copy**. The result lands on the clipboard *and* in the app container as Swift source ready to
# paste into `BuiltInThemes.swift`. To read it back without touching the device:
#
#   xcrun simctl get_app_container <udid> com.mochi.app data
#   cat "<that path>/Documents/keyart-placements.swift"
#
# "Apply to all" pushes the selected key's placement onto every key that has artwork — the usual
# case, since a whole illustration set comes out of one generation pass and tends to be uniformly
# too large or too bright.
set -euo pipefail

cd "$(dirname "$0")/.."

THEME="${1:-fantasy-castle-night}"
BUNDLE_ID="com.mochi.app"

DEVICE=$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; ids=[x["udid"] for v in d.values() for x in v]; print(ids[0] if ids else "")')
if [ -z "$DEVICE" ]; then
  DEVICE=$(xcrun simctl list devices available -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; ids=[x["udid"] for v in d.values() for x in v if "iPhone" in x["name"]]; print(ids[0] if ids else "")')
  [ -z "$DEVICE" ] && { echo "No iPhone simulator available."; exit 1; }
  xcrun simctl boot "$DEVICE"
fi

xcodegen generate >/dev/null

xcodebuild -project Mochi.xcodeproj -scheme MochiApp \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug build \
  -quiet

APP=$(xcodebuild -project Mochi.xcodeproj -scheme MochiApp -showBuildSettings -configuration Debug 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR/ {d=$2} / FULL_PRODUCT_NAME/ {n=$2} END {print d"/"n}')
APP="${APP/Debug-iphoneos/Debug-iphonesimulator}"

open -a Simulator --args -CurrentDeviceUDID "$DEVICE"
xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$DEVICE" "$APP"
xcrun simctl launch "$DEVICE" "$BUNDLE_ID" \
  -MochiThemeLab 1 -MochiThemeLabMode tweak -MochiThemeLabTheme "$THEME"

CONTAINER=$(xcrun simctl get_app_container "$DEVICE" "$BUNDLE_ID" data)
echo
echo "Art Tweak Lab launched for '$THEME'."
echo "After pressing Copy, the placements are readable here:"
echo "  cat \"$CONTAINER/Documents/keyart-placements.swift\""
echo
echo "To render one placement without tapping (useful for screenshots):"
echo "  xcrun simctl launch $DEVICE $BUNDLE_ID -MochiThemeLab 1 -MochiThemeLabMode tweak \\"
echo "    -MochiThemeLabTheme $THEME -MochiThemeLabSelect d -MochiThemeLabSeed '0.10,0.12,0.60,0.55'"
