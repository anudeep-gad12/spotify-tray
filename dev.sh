#!/bin/zsh
set -euo pipefail

ROOT_DIR="${0:A:h}"
cd "$ROOT_DIR"
APP_LOG_DIR="$HOME/Library/Logs/SpotifyTray"
APP_LOG_FILE="$APP_LOG_DIR/app.log"

case "${1:-open}" in
  open)
    xcodegen generate
    open SpotifyTray.xcodeproj
    ;;
  fresh)
    rm -rf .build/DerivedData
    xcodegen generate
    xcodebuild -project SpotifyTray.xcodeproj -scheme SpotifyTray -destination 'platform=macOS' -derivedDataPath .build/DerivedData build
    open SpotifyTray.xcodeproj
    ;;
  traces)
    mkdir -p "$APP_LOG_DIR"
    touch "$APP_LOG_FILE"
    tail -n 200 -f "$APP_LOG_FILE"
    ;;
  *)
    echo "usage: ./dev.sh [open|fresh|traces]" >&2
    exit 1
    ;;
esac
