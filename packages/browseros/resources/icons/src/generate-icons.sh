#!/usr/bin/env bash
# Regenerates all Crewm8 icon assets from crewm8-bear.svg and crewm8-logo.svg.
#
# Output format: black square background, white bear centered, ~68% of canvas.
# Run from this directory: ./generate-icons.sh
#
# Requires: rsvg-convert, imagemagick (magick), iconutil (macOS).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS="$(cd "$HERE/.." && pwd)"
BEAR="$HERE/crewm8-bear.svg"
LOGO="$HERE/crewm8-logo.svg"
LOGO_PNG="$HERE/crewm8-logo-bear.png"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

square_bear() {
  local out=$1 size=$2
  local inner=$(( size * 68 / 100 ))
  rsvg-convert "$BEAR" -w "$inner" -h "$inner" --keep-aspect-ratio -o "$TMP/bear_${size}.png"
  magick -size "${size}x${size}" canvas:black "$TMP/bear_${size}.png" -gravity center -composite "$out"
}

# macOS icon: zoom in on the bear so it fills the icon canvas. Per user
# direction, cropping left/right edges is acceptable since the source
# image has substantial black padding around the bear anyway.
#
# Pipeline:
#   1. -trim: strip surrounding black so we're working with just the
#      bear's bounding box.
#   2. +repage: reset virtual canvas so subsequent ops work from 0,0.
#   3. -resize ${size}x${size}^: scale so the SHORTER dimension matches
#      target (^ = fill-minimum); larger dim overflows.
#   4. -gravity center -extent: center-crop to exact target square.
#   5. -alpha off: guarantee every pixel is fully opaque.
macos_icon() {
  local out=$1 size=$2
  magick "$LOGO_PNG" \
    -trim +repage \
    -resize "${size}x${size}^" \
    -gravity center \
    -extent "${size}x${size}" \
    -alpha off \
    "$out"
}

wordmark_black_bg() {
  local out=$1 height=$2
  local width=$(( height * 786 / 229 ))
  rsvg-convert "$LOGO" -h "$height" --keep-aspect-ratio -o "$TMP/word_${height}.png"
  magick -size "${width}x${height}" canvas:black "$TMP/word_${height}.png" -gravity center -composite "$out"
}

wordmark_transparent() {
  local out=$1 height=$2
  rsvg-convert "$LOGO" -h "$height" --keep-aspect-ratio -o "$out"
}

transparent_bear() {
  local out=$1 size=$2
  rsvg-convert "$BEAR" -w "$size" -h "$size" --keep-aspect-ratio -o "$out"
}

echo "Top-level product_logo_*.png"
for s in 16 22 24 32 48 64 128 192 256 1024; do
  square_bear "$ICONS/product_logo_${s}.png" "$s"
done
cp "$ICONS/product_logo_256.png" "$ICONS/product_logo.png"

echo "Mono (22, transparent white bear for tray icons)"
transparent_bear "$ICONS/product_logo_22_mono.png" 22

echo "Name+wordmark variants"
wordmark_black_bg "$ICONS/product_logo_name_22.png" 22
wordmark_black_bg "$ICONS/product_logo_name_22_2x.png" 44
wordmark_transparent "$ICONS/product_logo_name_22_white.png" 22
wordmark_transparent "$ICONS/product_logo_name_22_white_2x.png" 44

echo "default_100_percent / default_200_percent"
for s in 16 32; do
  square_bear "$ICONS/default_100_percent/product_logo_${s}.png" "$s"
  square_bear "$ICONS/default_200_percent/product_logo_${s}.png" "$(( s * 2 ))"
done
wordmark_black_bg "$ICONS/default_100_percent/product_logo_name_22.png" 22
wordmark_transparent "$ICONS/default_100_percent/product_logo_name_22_white.png" 22
wordmark_black_bg "$ICONS/default_200_percent/product_logo_name_22.png" 44
wordmark_transparent "$ICONS/default_200_percent/product_logo_name_22_white.png" 44

echo "Linux"
for s in 24 48 64 128 256; do
  square_bear "$ICONS/linux/product_logo_${s}.png" "$s"
done
square_bear "$TMP/crewm8_32.png" 32
magick "$TMP/crewm8_32.png" "$ICONS/linux/product_logo_32.xpm"

echo "ChromeOS"
square_bear "$ICONS/chromeos/chrome_app_icon_32.png" 32
square_bear "$ICONS/chromeos/chrome_app_icon_192.png" 192
square_bear "$ICONS/chromeos/crosh_app_icon_256.png" 256
square_bear "$ICONS/chromeos/webstore_app_icon_16.png" 16
square_bear "$ICONS/chromeos/webstore_app_icon_128.png" 128

echo "macOS .icns (squircle shape with transparent padding)"
ICONSET="$TMP/crewm8.iconset"
mkdir -p "$ICONSET"
macos_icon "$ICONSET/icon_16x16.png" 16
macos_icon "$ICONSET/icon_16x16@2x.png" 32
macos_icon "$ICONSET/icon_32x32.png" 32
macos_icon "$ICONSET/icon_32x32@2x.png" 64
macos_icon "$ICONSET/icon_128x128.png" 128
macos_icon "$ICONSET/icon_128x128@2x.png" 256
macos_icon "$ICONSET/icon_256x256.png" 256
macos_icon "$ICONSET/icon_256x256@2x.png" 512
macos_icon "$ICONSET/icon_512x512.png" 512
macos_icon "$ICONSET/icon_512x512@2x.png" 1024
iconutil -c icns -o "$ICONS/mac/app.icns" "$ICONSET"
cp "$ICONS/mac/app.icns" "$ICONS/mac/AppIcon.icns"

echo "Windows .ico (multi-resolution)"
magick \
  "$ICONS/product_logo_16.png" \
  "$ICONS/product_logo_24.png" \
  "$ICONS/product_logo_32.png" \
  "$ICONS/product_logo_48.png" \
  "$ICONS/product_logo_64.png" \
  "$ICONS/product_logo_128.png" \
  "$ICONS/product_logo_256.png" \
  "$ICONS/win/chromium.ico"

# macOS Assets.car — the canonical Sequoia app-icon format. Without this,
# macOS draws a fallback "app tile" background behind app.icns, which
# renders as a visible gray frame around our black square. With a proper
# compiled Assets.car referencing an AppIcon asset, macOS treats the
# icon as authoritative and draws nothing behind it.
echo "macOS Assets.car (via xcrun actool)"
XCASSETS="$TMP/crewm8-icons.xcassets"
ICONSET_DIR="$XCASSETS/AppIcon.appiconset"
mkdir -p "$ICONSET_DIR"

macos_icon "$ICONSET_DIR/icon_16.png"   16
macos_icon "$ICONSET_DIR/icon_32.png"   32
macos_icon "$ICONSET_DIR/icon_64.png"   64
macos_icon "$ICONSET_DIR/icon_128.png"  128
macos_icon "$ICONSET_DIR/icon_256.png"  256
macos_icon "$ICONSET_DIR/icon_512.png"  512
macos_icon "$ICONSET_DIR/icon_1024.png" 1024

cat > "$ICONSET_DIR/Contents.json" <<'JSON'
{
  "images" : [
    {"idiom":"mac","scale":"1x","size":"16x16","filename":"icon_16.png"},
    {"idiom":"mac","scale":"2x","size":"16x16","filename":"icon_32.png"},
    {"idiom":"mac","scale":"1x","size":"32x32","filename":"icon_32.png"},
    {"idiom":"mac","scale":"2x","size":"32x32","filename":"icon_64.png"},
    {"idiom":"mac","scale":"1x","size":"128x128","filename":"icon_128.png"},
    {"idiom":"mac","scale":"2x","size":"128x128","filename":"icon_256.png"},
    {"idiom":"mac","scale":"1x","size":"256x256","filename":"icon_256.png"},
    {"idiom":"mac","scale":"2x","size":"256x256","filename":"icon_512.png"},
    {"idiom":"mac","scale":"1x","size":"512x512","filename":"icon_512.png"},
    {"idiom":"mac","scale":"2x","size":"512x512","filename":"icon_1024.png"}
  ],
  "info" : {"author":"xcode","version":1}
}
JSON

cat > "$XCASSETS/Contents.json" <<'JSON'
{"info":{"author":"xcode","version":1}}
JSON

COMPILED="$TMP/compiled"
mkdir -p "$COMPILED"
xcrun actool --compile "$COMPILED" \
  --platform macosx \
  --minimum-deployment-target 11.0 \
  --app-icon AppIcon \
  --include-all-app-icons \
  --output-partial-info-plist "$COMPILED/AppIcon-partial.plist" \
  "$XCASSETS" 2>&1 | tail -3

if [[ -f "$COMPILED/Assets.car" ]]; then
  cp "$COMPILED/Assets.car" "$ICONS/mac/Assets.car"
  echo "  -> $ICONS/mac/Assets.car ($(stat -f %z "$ICONS/mac/Assets.car") bytes)"
else
  echo "  WARN: actool did not produce Assets.car"
fi

echo "Done."
