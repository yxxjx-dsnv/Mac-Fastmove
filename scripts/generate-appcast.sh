#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
GENERATOR="${SPARKLE_GENERATE_APPCAST:-}"

if [[ -z "$GENERATOR" ]]; then
  echo "Set SPARKLE_GENERATE_APPCAST to the Sparkle generate_appcast tool path."
  exit 1
fi

mkdir -p "$DIST_DIR/appcast"
"$GENERATOR" "$DIST_DIR"

echo "Generated appcast metadata in $DIST_DIR/appcast"
