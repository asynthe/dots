# dots

Laptop NixOS config (host `p1`). The server lives in `~/git/flakes`.

## Conventions

- Every `.nix` under `nix/` is a flake-parts module, auto-imported, no
  `imports = [ ... ]` lists. One module per concern, named by
  `flake.modules.nixos.<name>`; hosts opt in by listing names. See
  [docs/DENDRITIC.md](docs/DENDRITIC.md).
- **`auth.nix` at the repo root is the one `.nix` outside `nix/`, and it stays
  there.** It is the entire account list — who may log in, with which ssh key,
  and which groups each one gets — so it is plain data, not a module, and being
  outside `nix/` is what stops import-tree loading it as one. Never move it
  under `nix/` and never declare a user anywhere else;
  `nix/nixos/base/auth.nix` is the aspect that reads it and the only thing that
  turns it into accounts. `~/git/flakes` keeps the same file, which is what
  makes an account portable between hosts. See [docs/AUTH.md](docs/AUTH.md).
- 4-space indent in `.nix`. Comments are `#` — `//` is the update operator.
  Keep them rare and at most two lines: a comment earns its place by saying
  *why*, never by restating the code. `TODO`s stay.
- `nix/nixos/base/` is what any machine gets, `nix/nixos/profiles/` bundles
  those for a role, and the rest of the aspect library is one file per domain.
  `~/git/flakes` has the same layout.
- `config/` is plain upstream dotfiles, symlinked into place, not generated.
  There is no home-manager. `config/<name>` becomes `~/.config/<name>`, but
  only if `<name>` is in the `CONFIGS` array in
  `scripts/home_setup.sh` — the list is explicit so a stray directory
  never silently becomes live config. **Adding a directory to `config/` is
  half the job; add it to that array too.** Anything that does not map
  name-for-name (VSCodium's two files, `.zshenv`, the firefox profile,
  `assets/icons/`) has its own `link` line below the array.
- Static payloads — wallpapers, fonts, icon themes, ascii art, images — live
  in `assets/`, one directory per kind. There is no `other/`.
- Scripts live flat in `scripts/`, bash only (PowerShell is in `~/git/dots-win`). Anything that sets up a machine or a
  `$HOME` belongs here, not in a one-off command — if it was worth doing once
  it is worth re-running after a reinstall. `scripts/` is for things you
  *execute*: a shell function sourced at every prompt is config, and belongs in
  `config/zsh/.zsh_functions` so `.zshrc` never has to reach outside
  `$ZDOTDIR` for it.
- Docs live in `docs/`, `SCREAMING_CASE.md`, one topic each. Terse: a line or
  two per point, no ASCII diagrams except where the shape *is* the content
  (the tree in `flakes/README.md`, the layout in `HOME_STRUCTURE.md`).

## $HOME

[docs/HOME_STRUCTURE.md](docs/HOME_STRUCTURE.md) defines the home directory
layout and is symlinked to `~/CLAUDE.md`. **Read it before creating, moving or
suggesting a path under `$HOME`.** The short version: seven directories, top
level is lifecycle not file type, all repos are flat under `~/git/`, and
`other/`/`misc/`/`temp/` are banned names.

Paths are absolute in `nix/` (`/home/meow/git/dots`) and `~`-relative in
`config/`. If you move a directory, `grep -rl` both forms across `config/`,
`nix/` and `scripts/` before assuming nothing referenced it.

## Applying changes

```bash
nh os switch                    # nix/ changes
./scripts/home_setup.sh         # dry run; --apply to do it
./scripts/sync_repos.sh         # pull every ~/git repo, fix .gitignore/.gitattributes
```

A new machine starts at `scripts/bootstrap.sh` (the curl one-liner is in
`HOME_STRUCTURE.md`): it clones this repo, links `~/CLAUDE.md`, then runs
`home_setup.sh`. It is fetched raw from gitlab, so it only knows what is pushed.

`nix/nixos/desktop/xdg.nix` sets env vars only — the data they point at is
moved by `home_setup.sh`, which symlinks the old path so a running agent
doesn't break before relogin. Change one without the other and things break
quietly.

## `hyprctl dispatch` takes Lua here

The Hyprland config is Lua, so `hyprctl dispatch` parses its argument as Lua —
the classic string syntax is a **silent** failure that still exits 0 under
`2>/dev/null`, which makes it a good way to run a test that measures nothing.

```bash
hyprctl dispatch workspace 2                        # error: ')' expected near '2'
hyprctl dispatch 'hl.dsp.focus({ workspace = 2 })'  # ok
hyprctl dispatch 'hl.dsp.window.fullscreen_state({ internal = 2, client = 2, action = "toggle" })'
```

Names follow `config/hypr/hyprland.lua`, and they are not the classic
dispatcher names: workspace switching is `hl.dsp.focus`, and `hl.dsp.workspace`
is a table (`hl.dsp.workspace.toggle_special`), not a function. Check the binds
in that file for the spelling before scripting one, and check the output rather
than discarding it.
