#!/usr/bin/env bash
# Creates /Applications/Crewm8.app as a Crewm8-branded copy of an installed
# BrowserOS.app. Non-destructive: original BrowserOS.app is untouched.
#
# Why this exists: rebuilding Chromium takes 100GB+ disk and hours. For quick
# local iteration on the dock icon + app name, we duplicate the signed
# BrowserOS app, swap app.icns, edit Info.plist, then ad-hoc re-sign.
# Re-signing is required because any modification invalidates the original
# developer signature.
#
# Run: ./apply-local-preview.sh
#
# Requires: macOS, codesign, installed /Applications/BrowserOS.app,
# generate-icons.sh already run (produces mac/app.icns).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="$(cd "$HERE/.." && pwd)"
SRC_APP="/Applications/BrowserOS.app"
DST_APP="/Applications/Crewm8.app"

if [[ ! -d "$SRC_APP" ]]; then
  echo "ERROR: $SRC_APP not found. Install BrowserOS.app first." >&2
  exit 1
fi

if [[ ! -f "$ICONS/mac/app.icns" ]]; then
  echo "ERROR: $ICONS/mac/app.icns not found. Run generate-icons.sh first." >&2
  exit 1
fi

echo "Removing any previous Crewm8.app preview"
rm -rf "$DST_APP"

echo "Copying BrowserOS.app to Crewm8.app"
cp -R "$SRC_APP" "$DST_APP"

echo "Swapping app icon"
cp "$ICONS/mac/app.icns" "$DST_APP/Contents/Resources/app.icns"

echo "Removing Assets.car (compiled asset catalog takes precedence over app.icns;"
echo "without xcodebuild we can't regenerate it, so we remove it to force the"
echo "fallback to our app.icns)"
rm -f "$DST_APP/Contents/Resources/Assets.car"

echo "Editing Info.plist (CFBundleName, DisplayName, Identifier)"
PLIST="$DST_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName Crewm8" "$PLIST" || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleName string Crewm8" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Crewm8" "$PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string Crewm8" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ai.crewm8.Crewm8" "$PLIST"

echo "Removing extended attributes (stale signatures, quarantine)"
xattr -cr "$DST_APP"

echo "Ad-hoc re-signing (required after modification)"
codesign --force --deep --sign - "$DST_APP" 2>&1 | tail -20

echo "Touching bundle to prompt Finder/Dock icon refresh"
touch "$DST_APP"

echo "Clearing icon services cache"
killall -9 IconServicesAgent 2>/dev/null || true
killall -9 Finder Dock 2>/dev/null || true

cat <<EOF

✓ Crewm8.app created at $DST_APP
  Launch it: open -a Crewm8
  Or: double-click /Applications/Crewm8.app in Finder

First launch may take a moment as macOS revalidates the ad-hoc signature.
If Gatekeeper blocks: right-click Crewm8.app → Open.

Original BrowserOS.app is untouched.
EOF
