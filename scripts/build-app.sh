#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
PROJECT_FILE="Mac Fastmove.xcodeproj"
SCHEME_NAME="LayerKeys"
APP_NAME="Mac Fastmove"
SOURCE_PACKAGES_DIR="$BUILD_DIR/SourcePackages"
WORKSPACE_STATE_FILE="$SOURCE_PACKAGES_DIR/workspace-state.json"

cd "$ROOT_DIR"

if [[ -f "$WORKSPACE_STATE_FILE" ]] && ! WORKSPACE_STATE_FILE="$WORKSPACE_STATE_FILE" SOURCE_PACKAGES_DIR="$SOURCE_PACKAGES_DIR" python3 - <<'PY'
import json
import os
import sys

workspace_state_file = os.environ["WORKSPACE_STATE_FILE"]
source_packages_dir = os.environ["SOURCE_PACKAGES_DIR"]
expected_prefix = source_packages_dir + os.sep

with open(workspace_state_file, "r", encoding="utf-8") as handle:
    workspace_state = json.load(handle)

artifacts = workspace_state.get("object", {}).get("artifacts", [])

for artifact in artifacts:
    path = artifact.get("path")
    if path and not path.startswith(expected_prefix):
        sys.exit(1)
PY
then
  echo "Detected stale SwiftPM artifact paths. Resetting $SOURCE_PACKAGES_DIR"
  rm -rf "$SOURCE_PACKAGES_DIR"
fi

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
