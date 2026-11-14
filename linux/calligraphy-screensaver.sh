#!/usr/bin/env bash
# Calligraphy Systems — Multi-Monitor Fullscreen Cinematic PCB Screensaver
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -n "${CALLIGRAPHY_SS_ROOT:-}" && -f "${CALLIGRAPHY_SS_ROOT}/index.html" ]]; then
  ROOT="$(cd "$CALLIGRAPHY_SS_ROOT" && pwd)"
elif [[ -f "$SCRIPT_DIR/../index.html" ]]; then
  ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ -f "$HOME/.local/share/calligraphy-screensaver/index.html" ]]; then
  ROOT="$HOME/.local/share/calligraphy-screensaver"
else
  echo "calligraphy-screensaver: cannot find index.html (run with --install first or set CALLIGRAPHY_SS_ROOT)" >&2
  exit 1
fi
VIDEOS="$ROOT/videos"
PLAYLIST="$VIDEOS/playlist.m3u"
HTML="$ROOT/index.html"
MODE="${1:-}"

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
  echo "Usage: $0 [--interactive|--single|--quad|--stop|--install|--video|--install-xscreensaver]"
  exit 0
fi

if [[ "$MODE" == "--stop" || "$MODE" == "stop" ]]; then
  pkill -f "calligraphy_screensaver_mon_" 2>/dev/null || true
  pkill -f "calligraphy_screensaver_profile" 2>/dev/null || true
  rm -rf /tmp/calligraphy_screensaver_mon_* 2>/dev/null || true
  echo "Stopped all Calligraphy screensaver windows."
  exit 0
fi

if [[ "$MODE" == "--install-xscreensaver" ]]; then
  LINE="calligraphy-ss:       ${ROOT}/linux/calligraphy-screensaver.sh \\n\\"
  echo "Add this program line to ~/.xscreensaver under 'programs:':"
  echo "  $LINE"
  exit 0
fi

if [[ "$MODE" == "--install" ]]; then
  SHARE_DIR="$HOME/.local/share/calligraphy-screensaver"
  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$SHARE_DIR/linux"
  if [[ "$ROOT" != "$SHARE_DIR" ]]; then
    cp -f "$ROOT/index.html" "$SHARE_DIR/index.html"
    if [[ -d "$ROOT/videos" ]]; then
      rm -rf "$SHARE_DIR/videos"
      cp -r "$ROOT/videos" "$SHARE_DIR/videos"
    fi
  fi
  install -m 0755 "$ROOT/linux/calligraphy-screensaver.sh" "$SHARE_DIR/linux/calligraphy-screensaver.sh"
  install -m 0755 "$ROOT/linux/calligraphy-screensaver.sh" "$HOME/.local/bin/calligraphy-screensaver"
  cat > "$HOME/.local/share/applications/calligraphy-screensaver.desktop" <<EOF
[Desktop Entry]
Name=Calligraphy Screensaver
Comment=Fullscreen cinematic PCB routing screensaver
Exec=$HOME/.local/bin/calligraphy-screensaver
Icon=preferences-desktop-screensaver
Terminal=false
Type=Application
Categories=Graphics;Viewer;
EOF
  echo "Installed launcher to ~/.local/bin/calligraphy-screensaver, assets to ~/.local/share/calligraphy-screensaver, and desktop entry."
  exit 0
fi

run_video() {
  if command -v mpv >/dev/null 2>&1 && [[ -s "$PLAYLIST" ]]; then
    exec mpv --fullscreen --loop-playlist=inf --really-quiet --no-audio --osd-level=0 --no-stop-screensaver "$PLAYLIST"
  fi
  if command -v vlc >/dev/null 2>&1 && [[ -s "$PLAYLIST" ]]; then
    exec vlc --fullscreen --loop --no-audio --quiet "$PLAYLIST"
  fi
  echo "calligraphy-screensaver: mpv/vlc or playlist.m3u not available" >&2
  return 1
}

if [[ "$MODE" == "--video" ]]; then
  run_video
  exit 1
fi

pkill -f "calligraphy_screensaver_mon_" 2>/dev/null || true
pkill -f "calligraphy_screensaver_profile" 2>/dev/null || true
sleep 0.1

WAKE_PARAM="&wake=1"
if [[ "$MODE" == "--interactive" || "$MODE" == "--browser" ]]; then
  WAKE_PARAM=""
fi

BROWSER_BIN=""
for cand in /usr/bin/chromium /usr/bin/chromium-browser /usr/bin/google-chrome; do
  if [[ -x "$cand" ]]; then
    BROWSER_BIN="$cand"
    break
  fi
done

title_requests_exit() {
  if command -v wmctrl >/dev/null 2>&1; then
    if wmctrl -l 2>/dev/null | grep -q 'CALLIGRAPHY_EXIT_NOW'; then
      return 0
    fi
  fi
  if command -v xprop >/dev/null 2>&1; then
    local ids id
    ids="$(xprop -root _NET_CLIENT_LIST 2>/dev/null | grep -oE '0x[0-9a-fA-F]+' || true)"
    for id in $ids; do
      if xprop -id "$id" WM_NAME _NET_WM_NAME 2>/dev/null | grep -q 'CALLIGRAPHY_EXIT_NOW'; then
        return 0
      fi
    done
  fi
  return 1
}

place_window_on_monitor() {
  local idx="$1" x="$2" y="$3" w="$4" h="$5"
  command -v wmctrl >/dev/null 2>&1 || return 0
  local class="calligraphy_ss_${idx}.Chromium"
  wmctrl -x -r "$class" -e "0,${x},${y},${w},${h}" 2>/dev/null || true
  wmctrl -x -r "$class" -b add,fullscreen 2>/dev/null || true
}

cleanup_profiles() {
  rm -rf /tmp/calligraphy_screensaver_mon_* 2>/dev/null || true
}

kill_recorded() {
  local p
  for p in "$@"; do
    [[ -z "${p:-}" ]] && continue
    kill -TERM -- "-$p" 2>/dev/null || kill -TERM "$p" 2>/dev/null || true
  done
}

# Tiny localhost /exit listener. Parent records Chromium PIDs; this process
# exits on the first GET /exit so the supervisor can tear everything down.
start_exit_listener() {
  EXIT_PORT="$(/usr/bin/python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')"
  setsid /usr/bin/python3 -c '
import http.server, socketserver, sys
port = int(sys.argv[1])
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(204 if self.path.startswith("/exit") else 404)
        self.end_headers()
        raise SystemExit(0)
    def log_message(self, *a):
        pass
socketserver.TCPServer.allow_reuse_address = True
httpd = socketserver.TCPServer(("127.0.0.1", port), H)
httpd.handle_request()
' "$EXIT_PORT" >/dev/null 2>&1 < /dev/null &
  EXIT_LISTENER_PID=$!
}

# Watch recorded child PIDs with kill -0 (never pgrep this script's cmdline).
run_exit_watchdog() {
  local listener="$1"
  shift
  local pids=("$@")
  while true; do
    if ! kill -0 "$listener" 2>/dev/null; then
      break
    fi
    local any_alive=0
    local p
    for p in "${pids[@]}"; do
      if kill -0 "$p" 2>/dev/null; then
        any_alive=1
      else
        break 2
      fi
    done
    if [[ "$any_alive" -eq 0 ]]; then
      break
    fi
    if title_requests_exit; then
      break
    fi
    sleep 0.2
  done
  kill_recorded "${pids[@]}"
  kill -TERM "$listener" 2>/dev/null || true
  cleanup_profiles
  exit 0
}

CHROME_PIDS=()
launch_one() {
  local idx="$1" x="$2" y="$3" w="$4" h="$5"
  local prof="/tmp/calligraphy_screensaver_mon_${idx}"
  rm -rf "$prof"
  mkdir -p "$prof"
  rm -f "$prof/SingletonLock" "$prof/SingletonSocket" "$prof/SingletonCookie"
  setsid "$BROWSER_BIN" \
    --user-data-dir="$prof" \
    --class="calligraphy_ss_${idx}" \
    --no-first-run \
    --no-default-browser-check \
    --window-position="${x},${y}" \
    --window-size="${w},${h}" \
    --start-fullscreen \
    --app="file://${HTML}?board=${idx}${WAKE_PARAM}&exit_port=${EXIT_PORT}" \
    >/tmp/screensaver_mon_${idx}.log 2>&1 < /dev/null &
  CHROME_PIDS+=("$!")
}

parse_monitors() {
  XS=(); YS=(); WS=(); HS=()
  if command -v xrandr >/dev/null 2>&1; then
    while IFS=' ' read -r x y w h; do
      [[ -z "${x:-}" ]] && continue
      XS+=("$x"); YS+=("$y"); WS+=("$w"); HS+=("$h")
    done < <(xrandr --listmonitors 2>/dev/null | awk '
      NR > 1 && match($0, /[0-9]+\/[0-9]+x[0-9]+\/[0-9]+[+-][0-9]+[+-][0-9]+/) {
        s = substr($0, RSTART, RLENGTH)
        if (match(s, /^[0-9]+/)) w = substr(s, RSTART, RLENGTH) + 0
        if (match(s, /x[0-9]+/)) h = substr(s, RSTART + 1, RLENGTH - 1) + 0
        if (match(s, /[+-][0-9]+[+-][0-9]+$/)) {
          xy = substr(s, RSTART, RLENGTH)
          if (match(xy, /[+-][0-9]+/)) {
            x = substr(xy, RSTART, RLENGTH) + 0
            y = substr(xy, RSTART + RLENGTH) + 0
          }
        }
        if (w > 0 && h > 0) print x, y, w, h
      }' | sort -n -k1,1 -k2,2)
  fi
}

finish_launch() {
  local n="${#XS[@]}"
  (
    sleep 1.2
    local i
    for ((i=0; i<n; i++)); do
      place_window_on_monitor "$i" "${XS[$i]}" "${YS[$i]}" "${WS[$i]}" "${HS[$i]}"
    done
  ) >/dev/null 2>&1 < /dev/null &
  setsid bash -c "$(declare -f title_requests_exit kill_recorded cleanup_profiles run_exit_watchdog); run_exit_watchdog ${EXIT_LISTENER_PID} ${CHROME_PIDS[*]}" \
    >/dev/null 2>&1 < /dev/null &
  echo "Launched Calligraphy screensaver on ${n} display(s) (Esc / Q / mouse wake exits all; exit_port=${EXIT_PORT})."
}

if [[ -n "$BROWSER_BIN" ]]; then
  export DISPLAY="${DISPLAY:-:0}"
  start_exit_listener
  if [[ "$MODE" == "--single" ]]; then
    XS=(0); YS=(0); WS=(1920); HS=(1080)
  else
    parse_monitors
    if [[ "${#XS[@]}" -eq 0 ]]; then
      if [[ "$MODE" == "--quad" ]]; then
        XS=(0 1920 3840 5760)
        YS=(0 0 0 0)
        WS=(1920 1920 1920 1920)
        HS=(1080 1080 1080 1080)
      else
        XS=(0); YS=(0); WS=(1920); HS=(1080)
      fi
    fi
  fi
  local_idx=0
  for ((local_idx=0; local_idx<${#XS[@]}; local_idx++)); do
    launch_one "$local_idx" "${XS[$local_idx]}" "${YS[$local_idx]}" "${WS[$local_idx]}" "${HS[$local_idx]}"
  done
  finish_launch
  exit 0
fi

run_video || true
if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "$HTML"
fi
echo "calligraphy-screensaver: no browser, mpv, or vlc found" >&2
exit 1
