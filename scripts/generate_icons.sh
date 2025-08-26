#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_ICON="$ROOT_DIR/art/icon-1024.png"
APPICON_DIR="$ROOT_DIR/DartTracker/Resources/Assets.xcassets/AppIcon.appiconset"

if [[ ! -f "$SRC_ICON" ]]; then
  echo "Missing source icon at $SRC_ICON" >&2
  exit 1
fi

mkdir -p "$APPICON_DIR"

sizes=(
  120
  180
  152
  167
  1024
)

for s in "${sizes[@]}"; do
  /usr/bin/sips -s format png --resampleWidth "$s" "$SRC_ICON" --out "$APPICON_DIR/icon-$s.png" >/dev/null
done

cat > "$APPICON_DIR/Contents.json" <<'JSON'
{
  "images" : [
    { "idiom" : "iphone", "size" : "60x60", "scale" : "2x", "filename" : "icon-120.png" },
    { "idiom" : "iphone", "size" : "60x60", "scale" : "3x", "filename" : "icon-180.png" },
    { "idiom" : "ipad",   "size" : "76x76", "scale" : "2x", "filename" : "icon-152.png" },
    { "idiom" : "ipad",   "size" : "83.5x83.5", "scale" : "2x", "filename" : "icon-167.png" },
    { "idiom" : "ios-marketing", "size" : "1024x1024", "scale" : "1x", "filename" : "icon-1024.png" }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
JSON

echo "App icons generated in $APPICON_DIR"


