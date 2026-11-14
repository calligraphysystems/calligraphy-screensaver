# Calligraphy Screensaver

Fullscreen cinematic showcase of **Calligraphy Systems** 45° octilinear copper routing on open-source multi-layer PCBs. Zero npm, zero CDN, zero build step.

Open `index.html` in any modern browser, or use the platform launchers for a looping 1920×1080 60 fps playlist.

Repository: [github.com/calligraphysystems/calligraphy-screensaver](https://github.com/calligraphysystems/calligraphy-screensaver)

## Boards

| Board | Stackup |
| :--- | :--- |
| c-dux Ergonomic Split Keyboard | 2L FR-4 (F.Cu / B.Cu 1oz) |
| Desk-Clock Circular LED Matrix | 2L FR-4 (F.Cu / B.Cu 1oz) |
| ADAU1966 16-Ch Pro Audio DAC | 4L FR-4 (F.Cu / In1 / In2 / B.Cu) |
| CC3200 Wi-Fi Quadcopter Flight Controller | 4L FR-4 (F.Cu / In1 / In2 / B.Cu) |
| PocketBone Linux Single-Board Computer | 4L FR-4 (F.Cu / In1 / In2 / B.Cu) |
| Spikeling ESP32 Neuromorphic Simulator | 2L FR-4 (F.Cu / B.Cu 1oz) |

Every board is shown at **100% net closure** with **0 copper DRC violations**. Public copper is strictly **45° octilinear** (no curved traces).

## Browser screensaver

1. Open `index.html`.
2. Press `F` (or `F11`) for fullscreen.
3. The showcase endlessly cycles through every board with the **Physical Synthesis Telemetry** side overlay and **Convergence Trace**.

| Key | Action |
| :--- | :--- |
| `F` / `F11` | Fullscreen |
| `Space` | Pause / resume |
| `←` `→` | Previous / next board |
| `1`–`6` | Jump to a board |
| `T` | Toggle top copper (F.Cu) |
| `I` | Toggle inner copper |
| `V` | Toggle vias |
| `[` / `]` | Playback speed 0.5× / 1× / 2× |
| `Esc` / `Q` | Exit (sets title `CALLIGRAPHY_EXIT_NOW`, posts `BroadcastChannel`, and hits `?exit_port=` if present) |

Click **EXIT (ESC)** in the bottom HUD (`#exitSsBtn` uses `pointer-events: auto`). Launchers that pass `?wake=1` arm mouse/pointer/wheel exit after **800 ms** with an **18 px** deadband (cursor origin is sampled when the arming window starts). Help (`[?]` / `.help-wrap`) does not wake-exit.

## Linux

```bash
chmod +x linux/calligraphy-screensaver.sh
./linux/calligraphy-screensaver.sh
./linux/calligraphy-screensaver.sh --install
./linux/calligraphy-screensaver.sh --video
```

Chromium/Chrome is preferred: one fullscreen `--app` window per **xrandr** monitor (`?board=N&wake=1&exit_port=`). If xrandr reports **0** monitors, a **single** 1920×1080 window is used unless `--quad` is passed. `--video` plays `videos/playlist.m3u` in mpv/vlc. A localhost `/exit` listener plus recorded child PIDs (not self-matching `pgrep`) closes every window together. See `linux/README.md`.

## macOS

Double-click `macos/calligraphy-screensaver.command`. Prefers Chrome/Brave/Edge fullscreen `--app ?wake=1`, then `mpv`, then Safari. See `macos/README.md`.

## Windows

Run `windows/calligraphy-screensaver.bat` or `.ps1`. Prefers Edge/Chrome/Brave fullscreen `--app ?wake=1`, else mpv playlist, else the default browser. See `windows/README.md`.

## What the overlay reports

The right-hand **Physical Synthesis Telemetry** panel is a live design-rule HUD:

- Stackup (actual copper layer count, e.g. `4L FR-4 (F.Cu / In1 / In2 / B.Cu)`)
- Pad matrix, 45° octilinear routing rule, active search window
- Clearance slack, per-layer copper segment counts, interlayer vias
- Remaining airwires and DRC clearance (`0` violations on these boards)

The **Convergence Trace** plots open airwires (crimson) against clearance slack (emerald) as each board closes.

## Credits

Open-hardware source boards remain the work of their original authors. This package visualizes completed 45° octilinear routing produced by Calligraphy Systems.

- [calligraphyeda.com](https://calligraphyeda.com)
- [@CalligraphyEDA](https://x.com/CalligraphyEDA)

## License

MIT © Calligraphy Systems LLC
