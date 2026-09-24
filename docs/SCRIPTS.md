# Scripts

What each script in `scripts/` is for and the reasoning that used to sit in its
header. Bash only, flat, dry-run by default where it changes anything — see the
conventions in [../CLAUDE.md](../CLAUDE.md).

## bootstrap.sh

First thing to run on a new machine. Clones this repo to `~/git/dots`, points
`~/CLAUDE.md` at the `$HOME` layout doc, then hands off to `home_setup.sh`.

```bash
curl -fsSL https://gitlab.com/asynthe/dots/-/raw/main/scripts/bootstrap.sh | bash
curl -fsSL https://gitlab.com/asynthe/dots/-/raw/main/scripts/bootstrap.sh | bash -s -- --apply
```

Without `--apply`, `home_setup.sh` only prints what it would do. Safe to
re-run: an existing clone is pulled rather than re-cloned. No git yet on a
fresh NixOS? Prefix with `nix-shell -p git --run '...'`.

The clone is over https because a new machine has no ssh key registered
anywhere yet; the remotes are switched to ssh afterwards so pushing works once
it does. `origin` then fetches from gitlab and pushes to both, with `gitlab`
and `github` kept as separate remotes for one-offs.

`~/CLAUDE.md` is linked here rather than left to `home_setup.sh` so an agent
opened on the machine knows the layout before `--apply` has ever run. A real
file at that path is left alone, with a warning — merge it by hand.

## home_setup.sh

Builds the `$HOME` layout and migrates an old one into it. Idempotent.
`./home_setup.sh` checks, `--apply` does it. See
[HOME_STRUCTURE.md](HOME_STRUCTURE.md) for the layout itself.

The XDG *variables* are set by nix (`nix/nixos/desktop/xdg.nix`); this script
only moves the data those variables now point at. **A symlink is left at every
old path**, so anything already running — gpg-agent, a shell — keeps working
until relogin. Wine prefixes are pulled out of the stock prefix into the
`wine/prefix/<app>` layout. gnupg is the one migration that actually cares
about the resulting permissions.

**Symlinks into the repo.** There is no home-manager: every dotfile reaches
`$HOME` as a symlink from this repo, and this script is the only place that
mapping is written down. A directory added to `config/` is **not live** until
it appears in the `CONFIGS` array here or matches the name-for-name rule.
The array is explicit rather than globbed so a stray directory — a backup, a
half-finished port — never silently becomes live config.

Three cases a plain `ln -s` loop gets wrong:

- **A real directory is never clobbered.** A config directory with local state
  in it is someone's data until proven otherwise; the script warns and leaves
  it.
- **VSCodium is linked per file.** `~/.config/VSCodium` also holds `Cache/`,
  `Cookies`, `Crashpad/` and `workspaceStorage/`; symlinking the directory
  hands the whole profile to git and breaks the editor.
- **Firefox's `user-overrides.js`** has to land inside whatever the profile
  directory is called today. The profile is under `~/.config/mozilla` here (the
  `MOZ_LEGACY_PROFILES=0` layout), and both that and `~/.mozilla` are globbed
  so it survives either.

Cursor and icon themes ship in `assets/icons`, not `config/`. Launcher wrappers
ship in `scripts/bin` and are linked into `~/.local/bin` — anything that needs
a `WINEPREFIX` or a long exe path in front of it belongs there rather than as a
loose script nothing tracks. `config/powershell` is for the Windows/Termux
side, placed by `~/git/dots-win/scripts/setup.ps1`; nothing to do on Linux.

**Stray zsh dotfiles.** `.zshenv` is the only zsh file that belongs at `$HOME`
— it is what zsh reads before `ZDOTDIR` exists, and all it does is point at
`~/.config/zsh`. Anything else matching at root is a leftover from before
`ZDOTDIR`, or from another machine. Regenerable files are dropped; config and
history with real content in them are left with a warning, since they may hold
settings worth folding into `$ZDOTDIR` rather than losing.

**Pruning.** A link into this repo whose source is gone means the config was
deleted from `config/`, so the link is dead weight and goes. Links pointing
anywhere else are not ours to judge and are only reported.

## sync_repos.sh

Pulls every repo under `~/git` and enforces the shared `.gitignore` (`.claude`,
`.DS_Store`) and the LF `.gitattributes`. Nested repos are skipped — a repo
inside another repo is that repo's business, which is what `audioland` is.

On a failed pull, git's last line is usually advice rather than the problem, so
the first `error`/`fatal` line is what gets reported. `.claude` is enforced at
the repo root only, and the common spellings (`.claude`, `.claude/`,
`/.claude`, `**/.DS_Store`) are all accepted rather than duplicated. A last
line with no trailing newline is handled so appending does not glue two rules
together.

## firefox_clean.sh

Drops every cookie and site-storage origin that is **not** inside a container,
so unsorted browsing stays disposable while `personal`, `study` and `events`
keep their logins. Run at login by the `firefox-clean` aspect, before Firefox
starts.

```bash
./firefox_clean.sh                          # check only
./firefox_clean.sh --apply
./firefox_clean.sh --apply --permissions    # also reset site permissions
```

What survives, and why:

| pattern | why |
| --- | --- |
| `^userContextId=N` | container data — the whole point |
| `moz-extension+++` | extension storage. Multi-Account Containers keeps its site→container assignments here, so wiping it destroys the mapping this script exists to protect |

History and bookmarks are never touched: `places.sqlite` has no container tag
and is not opened.

**The liveness guard.** Editing `cookies.sqlite` under a running Firefox either
loses the delete — it flushes its in-memory cookie set back over you — or
corrupts the DB, and pulling `storage/` directories out from under open tabs
breaks their IndexedDB. `pgrep -x firefox` does **not** work here: the NixOS
wrapper truncates `comm` to `.firefox-wrappe`, so an `-x` check reports "not
running" against a live browser. The real binary path is matched instead. The
lock symlink is a second signal — its target encodes the pid as
`127.0.0.2:+PID` — but it survives a crash, so the pid is verified rather than
the symlink's existence.

**Site storage** is localStorage, IndexedDB and service workers: one directory
per origin, with the container tag carried in the directory name.
`storage.sqlite` is QuotaManager's index of that tree; removing directories
behind its back leaves it stale, so it is deleted and Firefox rebuilds it from
what is actually on disk. `storage/permanent` is extension IndexedDB and is
never touched.

**Permissions are opt-in** because `moz_perms` has no container tag at all —
every row is global, so there is nothing to "keep for containers", and clearing
it only buys re-prompting for notifications and cookie banners everywhere.

The cache is regenerable, not container-tagged, and not worth filtering.

## firefox_forget.sh

Forgets one or more domains: their history, and optionally cookies and site
storage. The complement of `firefox_clean.sh` — that one works by container and
spares history; this one works by host and goes after it.

```bash
./firefox_forget.sh reddit.com                      # check only
./firefox_forget.sh --apply reddit.com x.com
./firefox_forget.sh --apply --cookies reddit.com    # also cookies + storage
./firefox_forget.sh --apply --containers ...        # reach inside containers
```

Subdomains come too: `reddit.com` takes `www.` and `old.` with it.

**Bookmarks survive.** A bookmarked page is a `moz_places` row that
`moz_bookmarks` points at (`foreign_count > 0`); deleting it would leave a
dangling bookmark, so those rows are stripped of their visit record and kept.

**Host matching.** `moz_places` stores the host reversed with a trailing dot —
`www.reddit.com` is `moc.tidder.www.` — so `moc.tidder.%` matches the bare
domain and every subdomain in one pattern, with no `OR`. Cookies match on host
plus any third-party cookie partitioned under the site, where
`originAttributes` carries `^partitionKey=%28https%2Creddit.com%29` (and a
`%2C443%29` variant). `instr()` is used rather than `LIKE` because those `%`
sequences are literal there, not wildcards. Storage origin directories have
two shapes: the site's own (`https+++www.reddit.com`) and a third party
partitioned under it (`https+++x.com^partitionKey=…reddit.com…`).

Cookies and storage are off by default: forgetting a domain from history is a
different want from being logged out of it, and the second is the one that
costs you.

The same liveness guard as `firefox_clean.sh` applies, for the same reason.

## book_preview.sh

Cover preview for the `book` fzf picker (see `$ZDOTDIR/.zsh_functions`).
Renders page 1 of a PDF to a cached PNG and draws it with whatever image
protocol the terminal speaks, falling back to a plain text card — which is also
all a non-PDF gets. The cache key includes mtime and size, so a replaced file
re-renders.

Inside tmux the backend drops to `chafa`, since kitty's graphics protocol needs
passthrough. `--unicode-placeholder` keeps the image anchored to the preview
window as fzf redraws it, and the trailing `sed` collapses the bare reset line
kitty emits, which fzf would otherwise read as an extra scrolled line.

## check_big_file_git.sh

Lists the largest objects in a git repo, [from this
answer](https://stackoverflow.com/questions/9456550/how-can-i-find-the-n-largest-files-in-a-git-repository).

## bin/

Launcher wrappers, linked into `~/.local/bin` by `home_setup.sh`. Currently
`musicbee`, which needs its `WINEPREFIX` set in front of it.
