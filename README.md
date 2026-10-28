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

## Layout

| path | what |
| --- | --- |
| `flake.nix`, `nix/` | NixOS system, dendritic flake-parts ([docs/nix.md](docs/nix.md)) |
| `config/` | dotfiles, symlinked into `~/.config` by `scripts/home_setup.sh` |
| `scripts/` | bootstrap, Hyprland helpers, backups, repo maintenance |
| `gentoo/` | Gentoo install notes and `/etc/portage`, kept for future installs |
| `windows/` | Windows setup scripts |
| `docs/` | why things are the way they are ([nix](docs/nix.md), [hyprland](docs/hyprland.md), [ai](docs/ai.md)) |
| `secrets/` | sops-encrypted, age key from `~/git/auth` |

## Install

```sh
nix run nixpkgs#git -- clone https://gitlab.com/asynthe/dots.git ~/git/dots
sudo nixos-rebuild switch --flake ~/git/dots#p1
~/git/dots/scripts/bootstrap.sh --apply
```

After that, `nh os switch` rebuilds, `nix fmt` formats and `nix flake check`
verifies.

## My current setup

| Device            | OS               |
| ----------------- | ---------------- |
| Thinkpad P1 Gen 7 | NixOS            |
| Macbook Air M2    | macOS            |


*Resources*
- [Nice collection of ASCII art](https://steamcommunity.com/sharedfiles/filedetails/?id=3079007278)
- <https://github.com/43PR/dotfiles>

*Thanks*
- SCL: TX-02 Font
