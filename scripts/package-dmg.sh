#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Mac Fastmove"

"$ROOT_DIR/scripts/build-app.sh"

rm -f "$DIST_DIR/$APP_NAME.dmg"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DIST_DIR/$APP_NAME.app" \
  -ov \
  -format UDZO \
  "$DIST_DIR/$APP_NAME.dmg"

echo "Created DMG at $DIST_DIR/$APP_NAME.dmg"
