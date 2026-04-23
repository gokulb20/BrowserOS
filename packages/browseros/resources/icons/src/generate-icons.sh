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
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

square_bear() {
  local out=$1 size=$2
  local inner=$(( size * 68 / 100 ))
  rsvg-convert "$BEAR" -w "$inner" -h "$inner" --keep-aspect-ratio -o "$TMP/bear_${size}.png"
  magick -size "${size}x${size}" canvas:black "$TMP/bear_${size}.png" -gravity center -composite "$out"
}

# macOS icon: pure-black full-canvas square, no rounded corners. All
# pixels are fully opaque black, so there is no transparent region for
# the dock's translucent background to bleed through as a light rim.
# Bear centered at ~65% of canvas.
macos_icon() {
  local out=$1 size=$2
  local bear=$(( size * 65 / 100 ))
  rsvg-convert "$BEAR" -w "$bear" -h "$bear" --keep-aspect-ratio -o "$TMP/bear_m${size}.png"
  magick -size "${size}x${size}" canvas:black \
    "$TMP/bear_m${size}.png" -gravity center -composite \
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

echo "Done."
