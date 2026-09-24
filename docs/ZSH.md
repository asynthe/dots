# Shell functions

What each function in `config/zsh/.zsh_functions` is for and the reasoning that
used to sit above it. The file itself keeps one-line comments at most — the same
split as [SCRIPTS.md](SCRIPTS.md), for the same reason: a function you read once
a year shouldn't cost you a screen of prose every time you open the file.

`.zshrc` sources `.zsh_functions` and `.zsh_aliases` from `$ZDOTDIR`. Anything
sourced at every prompt is config and lives here; anything you *execute* is a
script in `scripts/` — see [../CLAUDE.md](../CLAUDE.md).

## `yy` — yazi that changes your directory

`yazi` alone can't move its parent shell, so the wrapper passes `--cwd-file`,
reads the path yazi wrote on exit and `cd`s there. `yazi`, `l` and `lf` are all
aliased to it.

If you ever see a `FUNCNEST` error, the alias is recursing into itself — `unset
yy`, then call `\yazi` or `command yazi`.

## `h` — atuin

Interactive history search that puts the chosen command **on the prompt**
instead of running it (`print -z`), so you get to edit it first. `hist` is the
same thing.

## `book` and `pdf`

`book` is an fzf picker over `$BOOK_DIR` (default
`~/archive/media/book/reading`), multi-select with tab, previewing through
`scripts/book_preview.sh`. It hands the picks to `pdf`.

`pdf` opens each argument in zathura, detached — same idiom as `drop` below,
predating it.

## `drop` and `dropl` — detach a command from the shell

```zsh
drop mpv file.mkv      # prompt back immediately, survives the terminal closing
dropl someapp          # same, but output appended to a log
```

`setsid -f` puts the process in a **new session** with no controlling terminal,
so the SIGHUP the kernel sends when the terminal closes never reaches it, and
^C in that terminal doesn't either. `-f` always forks, so the parent exits and
there is no job left to `disown`.

Each redirection earns its place:

- `>/dev/null 2>&1` — in that order. Written the other way round, `2>&1` only
  aims stderr at the terminal stdout still points to.
- `</dev/null` — a program that reads stdin with no tty is stopped with
  SIGTTIN otherwise.

`dropl` writes to `${XDG_STATE_HOME}/drop/<cmd>.log`, appending, for when
something silently fails to start. `${1:t}` is zsh's tail modifier, so
`/usr/bin/mpv` logs to `mpv.log`.

**This defeats signals, not cgroups.** The process stays in the terminal's
systemd scope, so stopping that unit still takes it down. Anything meant to
outlive the session wants its own unit — `uwsm app -- foo`, which is what
`config/hypr/hyprland.lua` uses for autostart.

The long version, with the job-control background: `~/git/notes/guide/shell.md`.

## `flatpak_run` and friends

`flatpak_check` fails loudly if flatpak isn't installed. `flatpak_run` checks
whether the app id is installed, offers to install it from flathub if not, then
runs it. `fightcade`, `ps3`, `pinball` and `upscayl` are one-line wrappers over
it — the pattern is there so adding a flatpak is one line, not five.

## `blank` — judge the glass

Blanks the terminal to nothing: no prompt, no cursor, no scrollback, so what is
left on screen is the bare hyprglass slab. Any key returns.

Ghostty runs `background-opacity = 0`, so text is the only thing it paints —
with the text gone there is nothing between the wallpaper and the glass. That
makes this the only honest way to judge a tint or blur change. See
[HYPRGLASS.md](HYPRGLASS.md).

Two details in the implementation:

- **The alternate screen buffer, not `clear`.** The shell's screen comes back
  byte-for-byte on the way out: no scrollback wiped, no prompt redraw. The
  `\e[2J\e[H` is belt-and-braces — most terminals clear the alt buffer on
  switch, but it isn't guaranteed.
- **Two exit paths, both wired to restore.** Leaving the terminal on the alt
  screen with the cursor hidden is the one failure here that needs a `reset` to
  undo. zsh runs an `always` block on a return or an error but *not* on a
  signal, so Ctrl-C needs its own `trap`; `setopt local_traps` keeps that trap
  from outliving the function.

`read -rsk1` waits for one key. Modifiers alone send no byte, so holding Ctrl
won't wake it — any key that actually produces one will.

## `check_repo` — what's left to commit or push

Printed by `.zshrc` on every new shell. A repo with nothing to do prints
nothing.

```
check_repo      only problems
check_repo -a   plus a line for each repo that's fine
check_repo -r   ask github/gitlab now instead of trusting the cache
```

| Flag | Meaning |
| --- | --- |
| `[✎]` | uncommitted changes |
| `[⚠]` | unpushed, or diverged (fetch first) |
| `[↓]` | behind the host |
| `[✗]` | the host says the repo isn't there |
| `[?]` | no branch of that name on the host |
| `[!]` | nothing pushes to that host, or visibility drifted from the record |

### The record

The `record` array at the top is *where each repo should live* — hosts and
public/private, for `dots flakes notes study sakuhin auth`. Reality is checked
against it, so drift (a host missing, a private repo gone public) is flagged
too. Change the line and the repo together.

Repos resolve by name under `~/git`, then `~` — the phone keeps them flat — so
anything not cloned on this machine is skipped. The slug is `asynthe/<name>` on
every host.

### Why it doesn't slow the prompt

A new shell never waits on the network. What the hosts hold comes from a cache
under `$XDG_CACHE_HOME/check_repo`, refreshed by a disowned background job at
most every 10 minutes; local git state is read live. `-r` forces the refresh in
the foreground instead.

A push counts straight away, before the refresh catches up: a remote that
pushes to the host, with its tracking ref at HEAD, is proof enough.

The function never `cd`s. It runs at every prompt, and moving the shell's cwd
to print a status is how you end up somewhere unexpected.

### The two helpers

`_check_repo_refresh` asks every host about every repo in parallel. It is only
ever run in a subshell, because the `GIT_*` exports it sets are for those git
calls and not for the interactive shell. `GIT_SSH_COMMAND` *extends* whatever
`~/.gitconfig` has in `core.sshCommand` rather than replacing it — that setting
is what picks the key.

`_check_repo_ask` writes one host's answer whole, via a temp file and `mv`, so
a half-written cache file is never read: either `missing`, or the visibility
followed by the remote heads. Visibility is probed by an anonymous https
`ls-remote`, which only succeeds if the world can read the repo.

An unanswered host (offline, key not loaded) keeps what was already known —
only the host itself saying the repo isn't there marks it `missing`.

## `nix-clean` and `nix-roots`

```
nix-clean          keep the last 2 system generations, then GC
nix-clean 5        keep 5
nix-clean -n       dry run: show what would go, delete nothing
```

**Two things have to happen, in this order.** Deleting generations only drops
the profile symlinks; the store paths stay alive until a GC pass finds nothing
pointing at them. Running `nix-collect-garbage` on its own reclaims almost
nothing while old generations still root everything they reference.

The booted and current generation are never deleted, whatever the count says.
`sudo -v` runs first and alone, so a failed auth is an error rather than an
empty generation list that reads as "nothing to delete". Both the system
profile and the per-user profile are collected, and boot entries are refreshed
afterwards.

`nix-roots` lists what is still holding the store open when a pass frees less
than expected. It is usually a `result` symlink left in a project directory.
