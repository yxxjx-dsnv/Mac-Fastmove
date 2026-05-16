#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PROJECT_FILE="Mac Fastmove.xcodeproj"
SCHEME_NAME="LayerKeys"
APP_NAME="Mac Fastmove"

cd "$ROOT_DIR"

xcodegen generate

xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME_NAME" \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  build

mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR/$APP_NAME.app"
cp -R "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" "$DIST_DIR/$APP_NAME.app"

echo "Built app at $DIST_DIR/$APP_NAME.app"
