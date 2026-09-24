> **NOTE**
>
> I'm always updating this repository as it is my current system.

```
 ⠀⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣼⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣼⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣤⣶⣶⣿⣿⡗
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀
⣿⣿⡇⠜⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ⠀
⣿⣿⣿⣶⣿⣿⣿⣿⣿⠋⡹⠙⣿⣿⣿⡇⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⠛⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠁⠀⠀⠀⠀⠀⠀
⣿⣿⡿⠻⠿⠿⠿⠿⠛⠹⠑
⠟
```
*asynthe's system flake*, 2026

Clone this repository with the next commands, make sure `git-lfs` is installed to pull the wallpapers.
```bash
git lfs install
git clone https://github.com/asynthe/dots.git
# or https://gitlab.com/asynthe/dots.git
```

## My current setup

| Device            | OS               |
| ----------------- | ---------------- |
| Thinkpad P1 Gen 7 | NixOS (unstable) |
| Steam Deck        | SteamOS          |
| Samsung S24 Ultra | Android          |

*Docs*
- [Managing this config](docs/DENDRITIC.md) — the dendritic pattern: every `.nix` under `nix/` is a flake-parts module, auto-imported, no `imports = [ ... ]` lists.
- [Neovim keybinds](docs/KEYBINDS.md) — the editor layer. Hyprland and Ghostty are in the table below.
- [Shell functions](docs/ZSH.md) — what each function in `config/zsh/.zsh_functions` does, and the reasoning that used to sit in its header.
- [Contexts](docs/SESSION.md) — the `ALT + SHIFT + N` picker: four things in flight, one laid out at a time as a tiled workspace with per-window widths.
- [Wallpapers](docs/WALLPAPER.md) — the `ALT + W` picker: pick a still, awww sets it. No rotation, stills only.
- [`hyprland.lua`](docs/HYPRLAND.md) — the compositor config: plugins, decoration, window and layer rules.
- [Monitors](docs/MONITORS.md) — outputs, which workspaces live on which screen, and surviving a hotplug.
- [bar](docs/BAR.md) — the top-edge strip: signal bars and the address, and why the network code is a shell script and not `Quickshell.Networking`.
- [Bar surface](docs/SURFACE.md) — why the bar is opaque black, which layer gets blurred and which does not, and what the old translucent balancing act was.
- [`hyprglass` aspect](docs/HYPRGLASS.md) — liquid-glass decorations: building a Hyprland plugin on NixOS without hyprpm, and why layer glass is off.
- [Layout](docs/LAYOUT.md) — what `p1` is: disks, subvolumes, the rollback, and the two kernel workarounds.
- [Aspect notes](docs/ASPECTS.md) — why the non-obvious aspects are written the way they are.
- [Accounts](docs/AUTH.md) — `auth.nix`: who may log in, with which key, and why no aspect names a user.
- [Secrets](docs/SECRETS.md) — one sops file, nested keys, and the two decrypt paths.
- [`sarten` host](docs/SARTEN.md) — the ProLiant: adopted in place, disk layout, and the rebuild runbook.
- [`hermes` aspect](docs/HERMES.md) — Hermes Agent, shared by `p1` and `sarten`.
- [SOC lab](docs/LAB.md) — the plan for `sarten` as a lab: what the hardware can carry, the Windows gap, and the roadmap.
- [Wazuh](docs/WAZUH.md) — the SIEM on `sarten`: why it is a compose file outside the flake, the 4.14.7 pin, and what it can actually see.
- [The media stack](docs/MEDIA.md) — jellyfin, the arrs and qbittorrent: why downloads live under the media root, and why grouping movies by director cannot come from Radarr.
- [Databases](docs/DATABASE.md) — the SQL kit: duckdb to start, a loopback Postgres to grow into, and `vim-dadbod` so queries stay in a normal buffer.
- [Firefox](docs/FIREFOX.md) — two scripts on perpendicular axes: wipe by container sparing history, or forget by host taking it.
- [Termux](docs/TERMUX.md) — phone-side setup.

### `sarten`

```
sarten  192.168.1.135
│
├── media
│   ├── jellyfin        :8096
│   ├── radarr          :7878   movies
│   ├── sonarr          :8989   series + anime
│   ├── lidarr          :8686   music
│   ├── prowlarr        :9696   indexers
│   ├── bazarr          :6767   subtitles
│   └── qbittorrent     :8080
│
├── monitoring
│   ├── homepage        :8082   links to everything below
│   ├── grafana         :3000
│   └── prometheus      :9090
│
├── security
│   └── wazuh           :443
│
└── virt
    └── incus           :8443
```

## Keybinds

Three programs share the keyboard, and each gets its own layer so nothing
overlaps:

| Layer    | Trigger         | Owns                                       |
| -------- | --------------- | ------------------------------------------ |
| Hyprland | `Alt`           | windows, workspaces, monitors, screenshots |
| Ghostty  | `Ctrl+s`        | terminal splits, tabs, zoom, close         |
| Neovim   | everything else | the whole bare `Ctrl` layer, plus `Space`  |

Shaped around the HHKB Pro Hybrid Type-S: `Ctrl` sits on caps lock, so `Ctrl`
plus the home row is the cheapest chord on the board — which is why Neovim gets
it, and why Ghostty hides behind a `Ctrl+s` leader instead of the bottom-row
diamond keys. Ghostty takes exactly one bare `Ctrl` chord, `Ctrl+s` itself.
Nothing is bound to arrow keys: they need `Fn`, which Ghostty cannot use as a
modifier at all.

Neovim's own keys live in [docs/KEYBINDS.md](docs/KEYBINDS.md).

### Hyprland (`Alt`)

Defined in [`config/hypr/hyprland.lua`](config/hypr/hyprland.lua). Every
direction key also accepts the matching arrow key.

*Launch and session*

| Key                | Action                          |
| ------------------ | ------------------------------- |
| `Alt+Shift+Return` | Terminal (ghostty)              |
| `Alt+P`            | App launcher (fuzzel)           |
| `Alt+B`            | Browser (firefox)               |
| `Alt+V`            | Toggle pavucontrol              |
| `Alt+W`            | Wallpaper picker                |
| `Alt+Shift+B`      | Show / hide bar                 |
| `Alt+Shift+N`      | Context picker (session.sh)     |
| `Alt+Shift+C`      | Close window                    |
| `Alt+Shift+Z`      | Toggle the laptop screen        |
| `Alt+Shift+O`      | Shutdown menu                   |
| `Print`            | Screenshot a region             |
| `Shift+Print`      | Screenshot the focused monitor  |

*Windows*

| Key                  | Action                        |
| -------------------- | ----------------------------- |
| `Alt+h/j/k/l`        | Focus in that direction       |
| `Alt+Shift+h/j/k/l`  | Move window                   |
| `Alt+Ctrl+h/j/k/l`   | Resize window, 80px steps     |
| `Alt+Super+h/j/k/l`  | Nudge a floating window, 50px |
| `Alt+Tab`            | Cycle to next window          |
| `Alt+Shift+Tab`      | Cycle to previous window      |
| `Alt+F`              | Toggle fullscreen             |
| `Alt+Shift+F`        | Toggle floating               |
| `Alt+D`              | Toggle split direction        |
| `Alt+O`              | Toggle pseudo-tiling          |
| `Alt+Shift+P`        | Pin window                    |
| `Alt` + left-drag    | Move window                   |
| `Alt` + right-drag   | Resize window                 |

*Workspaces and monitors*

| Key                 | Action                       |
| ------------------- | ---------------------------- |
| `Alt+1`–`Alt+0`     | Go to workspace 1–10         |
| `Alt+Shift+1`–`0`   | Send window to workspace     |
| `Alt+,` / `Alt+.`   | Previous / next workspace    |
| `Alt+S`             | Toggle the scratchpad        |
| `Alt+Shift+S`       | Send window to the scratchpad |
| `Alt+[` / `Alt+]`   | Focus left / right monitor   |
| `Alt+Shift+,` / `.` | Focus left / right monitor   |

*Zoom and media*

| Key                    | Action                        |
| ---------------------- | ----------------------------- |
| `Alt+-` / `Alt+=`      | Zoom the screen out / in      |
| `Alt` + scroll         | Zoom the screen out / in      |
| `XF86Audio{Raise,Lower}Volume` | Volume ±5%            |
| `XF86AudioMute`        | Mute output                   |
| `XF86AudioMicMute`     | Mute microphone               |
| `XF86MonBrightness{Up,Down}`   | Brightness ±5%        |

Volume and brightness keys stay live while the screen is locked.

### Ghostty (`Ctrl+s`, then a key)

Defined in [`config/ghostty/config.ghostty`](config/ghostty/config.ghostty).
The leader is one-shot — it releases after a single action, and `Esc` or any
unbound key cancels it.

| Key              | Action                |
| ---------------- | --------------------- |
| `Ctrl+s h/j/k/l` | Focus split           |
| `Ctrl+s o`       | Focus next split      |
| `Ctrl+s \`       | New split right       |
| `Ctrl+s -`       | New split down        |
| `Ctrl+s z`       | Zoom split            |
| `Ctrl+s e`       | Equalize splits       |
| `Ctrl+s x`       | Close split or tab    |
| `Ctrl+s c`       | New tab               |
| `Ctrl+s [` / `]` | Previous / next tab   |
| `Ctrl+s 1`–`9`   | Go to tab             |
| `Ctrl+s r`       | Resize mode           |

Resize mode is the one exception to one-shot: it stays active so `h/j/k/l` can
repeat. `q` or `Esc` leaves it.

`Ctrl+Shift+R` reloads the config, and is bound outside the leader so it works
when a key table has gone wrong. Ghostty's stock `Ctrl+Shift+…` defaults (copy,
paste, new tab, search) are untouched and still live.

*Resources*
- [Nice collection of ASCII art](https://steamcommunity.com/sharedfiles/filedetails/?id=3079007278)
- <https://github.com/43PR/dotfiles>

*Thanks*
- RedDragon: 1920x1200 NASA Wallpaper Set
- SCL: TX-02 Font

