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
file is missing or names something deleted, it falls back to the first still in
the folder.

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
