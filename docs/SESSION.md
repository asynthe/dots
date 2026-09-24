# Contexts

Four unrelated things are in flight at once — the server, security study, the
data-analyst job hunt, the book — and none of them shares a screen with
another. `config/hypr/session.sh` lays one of them out as a tiled workspace,
each window given a width.

`ALT + SHIFT + N` opens a fuzzel picker; the script also runs from a shell.

| Context  | Workspace                                           | + more                    |
| -------- | --------------------------------------------------- | ------------------------- |
| `book`   | `typst watch` 10% · `nvim` 40% · `zathura` 50%       | —                         |
| `sarten` | `nvim` flakes 50% · `ssh sarten` 50%                 | wazuh, grafana, homepage  |
| `sec`    | `nvim` study 50% · shell 50%                         | THM/HTB/wazuh · burp      |
| `data`   | job boards 70% · `notes/work.md` 30%                 | —                         |

```sh
session.sh                 # pick with fuzzel
session.sh book            # the most recent book
session.sh book 0003       # or erotica, agustin -- any part of the name
session.sh -w 5 book       # force the first workspace
session.sh -n book         # print what it would launch
```

## Changing which book

Three ways, and the picker is the one to reach for:

- **From `ALT + SHIFT + N`**, choosing `book` puts up a second fuzzel listing
  the books, most recently worked on first — so the usual case is two Enters.
- **From a shell**, `session.sh book <anything in the name>`: `0003`,
  `erotica` and `0003_erotica` all reach the same book.
- **With no argument at all**, the most recent one. `typst watch` rewrites
  `book.pdf` in place every time it recompiles, so "most recent" is the book
  you last actually worked on rather than the one you last committed.

Each workspace group lands on the next *empty* workspace in **3–8**, so a
context never opens on top of work already in progress, 9–10 (chat, music) are
never touched, and 1–2 are left alone because `monitors.lua` pins those to the
laptop panel — every layout here is sized for the external. If there are not
enough free workspaces the script says so — including via `notify-send`, since
a keybind has no terminal to print to.

## Why it is not in the autostart

`hyprland.lua`'s `hyprland.start` block is for what is true of *every* session:
mpd, the vpn, bar, the wallpaper. Which of the four you are doing is a
decision you make when you sit down, not a property of the machine — starting
all four at login means four times the windows and three of them stale by
midday. So it is a keybind, and re-running it is how you switch.

## How the widths are set

Dwindle fixes a split's ratio from `dwindle:default_split_ratio` at the moment
the split is created, so the script sets it just before each launch and every
column lands exactly. Nothing is resized afterwards. `force_split = 2` puts
each new window to the right of the last, making launch order left-to-right
instead of following the cursor. Both are restored on exit, including on a
failure path.

For panes of `p1…pn` percent, the split that places pane `k` uses
`2 · p(k) / (100 − Σp(<k))` — pane `k`'s share of what is left, doubled,
because a ratio of 1.0 is an even split. Hyprland clamps outside 0.1–1.9.

## The four things that bite

Each of these silently produces a wrong layout rather than an error.

- **`hyprctl dispatch` and `hyprctl eval` are not interchangeable.** This build
  parses lua. `dispatch` wraps its argument as `hl.dispatch(<expr>)`, so it
  takes a dispatcher object — legacy `dispatch exec "..."` is read as lua and
  is a syntax error, while `hl.dsp.exec_cmd("...")` works. `eval` runs a
  statement for its side effect and is the only way in to `hl.config`
  (`hyprctl keyword` answers *"can't work with non-legacy parsers, use eval"*),
  but it does **not** dispatch: eval'ing an `hl.dsp.*` call builds the object
  and drops it, launching nothing.
- **Config writes are scheduled.** `hl.get_config` reads the new value back at
  once, but the layout engine keeps the old one until the refresh lands.
  `hl.exec_scheduled_prop_refresh_immediately()` is the flush.
- **A partial `hl.config` poke loses what it omits** once refreshed — the
  parsed config has no `force_split`, so a ratio-only write put it back to 0
  and the next window split toward the cursor. Both keys go in every poke.
- **Wait for each window to take focus before launching the next**, and for the
  last one before restoring. A window is listed by `hyprctl clients` a moment
  before it is tiled and focused, and the next split is taken against whatever
  is focused then. The last pane matters just as much: `restore()` otherwise
  outruns a window that has not mapped, and it tiles evenly.

Two smaller ones:

- **Session terminals use their own class**, `sess.ghostty`. The window rule in
  `hyprland.lua` floats `com.mitchellh.ghostty*` at a fixed size — right for a
  terminal you summon, wrong for one in a layout — and a different class falls
  straight through it into the tiler.
- **The workspace is focused before anything launches.** An exec workspace rule
  only binds windows spawned by that process, so a `firefox --new-window`
  served by an already-running firefox ignores it — but it still opens on the
  active workspace.

## Details

- **It announces itself** as `book session - neon architecture`: the context
  name, and for `book` the directory with its ordinal and underscores taken
  off. The other three are fixed labels — `server config`, `pentest + SOC`,
  `job hunt`.
- **`0000_examples` and `_template` are skipped** — scaffolding, not books.
- A book that has never been built is compiled once first, so zathura has a pdf
  to open before `typst watch` finishes its own first pass.
- The panes read left to right in writing order: the watch ticker, the source,
  then the page it renders to.
- zathura reloads on its own when typst rewrites the pdf.

## Adding a context

Write a `context_<name>` function that calls `pane <percent> <command>` per
column and `ws` to start another workspace, then add the name to `CONTEXTS`.
`term <cwd> [cmd...]` and `browse <url>...` build the command strings. Percents
in one workspace should add up to 100; the script warns if they do not.
