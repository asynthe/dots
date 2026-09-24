# hyprquickpaper

Wallpaper picker for Hyprland, bound to `ALT + W` in `config/hypr/hyprland.lua`.
Cycle with `h`/`l` (or the arrows, or the wheel), `Return` to apply, `Escape` to
cancel. That is the whole thing: pick one, it changes, nothing else happens.

| Key | |
|---|---|
| `h` `l` / `←` `→` / `,` `.` | one wallpaper |
| `u` `d` | one screenful |
| `Return` / `Space` / click | apply |
| `Escape` | cancel |

## Pieces

| File | |
|---|---|
| `shell.qml` | the picker UI |
| `cache.sh` | builds tile thumbnails, run on startup |
| `commands.sh` | what the picker calls once you pick |
| `config.json` | paths, tile count, border colour |
| `../../hypr/wallpaper.sh` | sets the wallpaper |

## Setting the wallpaper

Everything goes through **awww** — one daemon started by `hyprland.lua`, plus a
thin client per change. `wallpaper.sh` is the only thing that talks to it, so
the picker and the login path cannot disagree:

```
wallpaper.sh                    restore the last pick (run once at login)
wallpaper.sh --set FILE [FADE]  show FILE now (what commands.sh calls)
```

There is **no rotation** — the wallpaper changes only when you pick one. The
`--set` path writes the file to `~/.cache/quickshell/current-wallpaper`, and the
bare form reads it back at login so the wallpaper survives a reboot. If that
file is missing or names something deleted, it falls back to
`assets/backgrounds/minimal_dark_dots.jpg` — the one wallpaper kept in the repo, so a
fresh machine is never blank.

At login `wallpaper.sh` may beat `awww-daemon` to the socket, so the bare form
retries for a few seconds instead of giving up on the first failure.

## Stills only

The folder holds 26 JPEGs at 3440x1440. No mp4, no webm, no gif — a video
wallpaper needs a second backend (mpvpaper) drawing its own layer surface *over*
awww's, which means every switch has to kill the old process first, and a 21:9
loop on the 1920x1200 laptop panel needs `--panscan` or it letterboxes and shows
awww through the bars. Removed deliberately; `git log` has it if it is ever
wanted back.

`awww` does animate gifs natively, so dropping one in the folder would work, but
nothing here lists or thumbnails them.

## Thumbnails

`cache.sh` writes `<cache_path>/<filename-with-extension>.jpg`, skipping
anything already there. Thumbs are cropped to roughly the tile's shape and
always JPEG: a tile only ever shows a narrow slice of a 21:9 wallpaper, so
keeping full width meant decoding ~7x the pixels displayed, and PNG thumbs ran
2.5 MB apiece.

Stale thumbs are harmless; the picker only lists what is in the wallpaper
folder. To force a rebuild, `rm -rf ~/.cache/quickshell/thumbs`.

## awww-daemon has been dying

If the wallpaper stops changing and `ALT + W` does nothing, check the daemon:

```
pgrep -af awww-daemon || uwsm app -- awww-daemon
```

It went down twice unprompted while this was being set up, roughly around
display plugging and toggling, but that correlation is **not** established —
the test that appeared to show it was matching the process wrong. Cause unknown.
Nothing is logged: the scope exits without a journal entry or a coredump.

Match on the command line. `pgrep -x awww-daemon` never matches: NixOS wraps the
binary and Linux truncates the process name at 15 characters, so the running
process is `.awww-daemon-wr` and `-x` silently reports it as absent.

## Notes from the code

`config/quickshell/hyprquickpaper/shell.qml` is a fork of
[43PR/dotfiles](https://github.com/43PR/dotfiles) (`4b0412f`), itself a rework
of [iamsurjog/hyprquickpaper](https://github.com/iamsurjog/hyprquickpaper)
(`d380bee`), where `cache.sh` and the `config.json` keys come from. It needs
bash, jq, magick, ffmpeg and `~/.config/hypr/wallpaper.sh`, and runs as
`quickshell -c hyprquickpaper`.

Local changes on top of upstream:

- **Full-width layer anchors.** Upstream sets `implicitWidth: Screen.width`,
  which picks up the wrong monitor's width on a multi-head setup — a 1920 panel
  stranded in the middle of the 3440 display. Layer-shell anchors stretch the
  surface to whichever output it lands on instead.
- **Opens on the current wallpaper** rather than restarting from the middle of
  the folder. With no awww daemon running, it falls back to the middle.
- **Endless scroll.** Rather than a model of `folderModel`, `copies` of the
  folder are laid end to end starting in the middle one; each tile reads its
  image from `index % folderModel.count`, so the row repeats seamlessly and the
  ends sit thousands of tiles away in both directions. ListView only builds the
  handful of delegates actually on screen.
- **Selection-centred zoom via `StrictlyEnforceRange`.** Centring is ListView's
  job: the band is exactly the selected tile's width centred in the viewport, so
  the selection always sits mid-screen with the row fanning out either side.
  Doing it by hand meant computing `contentX` from item positions that had not
  been relaid out for the new tile widths yet — landing half a tile off — and
  over a strip this long, summing widths in closed form disagrees with
  ListView's own estimated coordinate space entirely. Dragging is disabled for
  the same reason: it only fights the centring.
- **Hover borders.** Hovering moves the border without moving the selection.
  Sliding the row under a stationary cursor makes Qt deliver both `entered` and
  `positionChanged` to whatever tile arrives under the pointer, so hover is
  gated on the cursor actually moving in viewport coordinates.
- A quick fade, and tile-shaped JPEG thumbnails.
