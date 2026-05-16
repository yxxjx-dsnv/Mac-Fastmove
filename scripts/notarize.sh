#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Mac Fastmove"
APP_PATH="$DIST_DIR/$APP_NAME.app"
ZIP_PATH="$DIST_DIR/$APP_NAME.zip"

if [[ -z "${APPLE_ID:-}" || -z "${APPLE_TEAM_ID:-}" || -z "${APPLE_APP_PASSWORD:-}" || -z "${DEVELOPER_ID_APPLICATION:-}" ]]; then
  echo "Missing notarization environment variables."
  echo "Required: APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD, DEVELOPER_ID_APPLICATION"
  exit 1
fi

"$ROOT_DIR/scripts/build-app.sh"

codesign \
  --deep \
  --force \
  --options runtime \
  --sign "$DEVELOPER_ID_APPLICATION" \
  "$APP_PATH"

rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

xcrun notarytool submit \
  "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --wait

xcrun stapler staple "$APP_PATH"

echo "Signed and notarized $APP_PATH"
