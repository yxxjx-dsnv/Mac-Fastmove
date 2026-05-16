#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="Mac Fastmove.xcodeproj"
SCHEME_NAME="LayerKeys"

cd "$ROOT_DIR"

xcodegen generate
xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME_NAME" -resolvePackageDependencies

echo "Generated $PROJECT_FILE and resolved package dependencies."
