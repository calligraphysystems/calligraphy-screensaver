# Linux launcher

Run `./calligraphy-screensaver.sh` from this folder (or `calligraphy-screensaver` after `--install`).

```text
./calligraphy-screensaver.sh
./calligraphy-screensaver.sh --single
./calligraphy-screensaver.sh --quad
./calligraphy-screensaver.sh --interactive
./calligraphy-screensaver.sh --video
./calligraphy-screensaver.sh --stop
./calligraphy-screensaver.sh --install
./calligraphy-screensaver.sh --install-xscreensaver
```

- Prefers Chromium/Chrome `--app` with `?wake=1&exit_port=` on each **xrandr** monitor (staggered `?board=`). Stale `SingletonLock` / `SingletonSocket` / `SingletonCookie` files under `/tmp/calligraphy_screensaver_mon_*` are removed before launch.
- If xrandr returns **0** monitors, falls back to **one** 1920×1080 window unless `--quad` is explicit.
- Exit supervisor runs for **single- and multi-monitor** launches: a localhost HTTP `GET /exit` listener, recorded Chromium PIDs (`kill -0`, never self-matching `pgrep`), and `wmctrl`/`xprop` `CALLIGRAPHY_EXIT_NOW`.
- `--video` uses `mpv` or `vlc` on `videos/playlist.m3u`.
- `--install` copies `index.html` and `videos/` into `~/.local/share/calligraphy-screensaver`, installs this launcher to `~/.local/bin/calligraphy-screensaver`, and writes a desktop entry to `~/.local/share/applications/calligraphy-screensaver.desktop`.
- `--install-xscreensaver` prints the xscreensaver program line to paste into `~/.xscreensaver`.
