#!/bin/bash
# Calligraphy Systems — macOS fullscreen cinematic PCB screensaver
# Double-click this file, or run it from Terminal.
# Preferred: Chrome/Brave/Edge --app kiosk. Fallback: mpv playlist, then Safari.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAYLIST="$ROOT/videos/playlist.m3u"
HTML="$ROOT/index.html"
URL="file://${HTML}?wake=1"

launch_chromiumish() {
  local app="$1"
  local bin="$2"
  if [[ -d "/Applications/${app}.app" ]]; then
    open -a "$app" --args --start-fullscreen --app="$URL"
    echo "Launched ${app} fullscreen --app screensaver (?wake=1). Esc/Q/mouse exits."
    exit 0
  fi
  if [[ -n "$bin" && -x "$bin" ]]; then
    "$bin" --start-fullscreen --app="$URL" >/dev/null 2>&1 &
    echo "Launched ${app} fullscreen --app screensaver (?wake=1). Esc/Q/mouse exits."
    exit 0
  fi
}

launch_chromiumish "Google Chrome" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
launch_chromiumish "Brave Browser" "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
launch_chromiumish "Microsoft Edge" "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"

if command -v mpv >/dev/null 2>&1 && [[ -s "$PLAYLIST" ]]; then
  exec mpv --fullscreen --loop-playlist=inf --really-quiet --no-audio --osd-level=0 "$PLAYLIST"
fi
open -a Safari "$HTML"
osascript -e 'tell application "Safari" to activate' >/dev/null 2>&1 || true
echo "Press Control-Command-F in Safari for fullscreen. Space pauses; T/I/V layers; [ ] speed; arrow keys change boards."
