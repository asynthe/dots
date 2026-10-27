# p1: Gentoo -> NixOS migration

State backup: `root@192.168.1.135:/root/backups/p1-state/p1_state_backup_20261026.tar.gz`
(sarten, 1.2G, sha256 `c7423002f99b1cc5e2373855a4f9a6fc8dd3fed66d45f3b8cc249113a7976105`)

## What's covered vs. not

| | where | how to get it back |
| --- | --- | --- |
| system config, disk layout | `~/git/dots/nix`, `flake.nix` | `nixos-rebuild --flake ~/git/dots#p1` (disko.nix mirrors the current mdadm RAID0 + LUKS2 + btrfs layout) |
| dotfiles (`~/.config/<app>`) | `~/git/dots/config` | `scripts/bootstrap.sh` then `scripts/home_setup.sh --apply` — NOT home-manager, same symlink convention on both distros |
| git repos (dots, notes, sakuhin, auth, sarten, tidal-daemon, study, openhand, rea, resume-latex) | gitlab + github, `asynthe/<name>` | clone each (needs SSH key from the state tar first) |
| SSH keys, shell rc, .ansible, .atuin, real (non-symlinked) app configs (Signal, vesktop, Mozilla, tidal-hifi, VSCodium, bruno, GIMP, Mullvad, mozc, fcitx5, systemd user units) | state tar | extract to `$HOME` |
| Hermes: config.yaml, .env, auth.json, google tokens, memories, skills, sessions, vault, kanban/shared-state/state.db, cron, SOUL.md, backups, install_id | state tar, under `.local/share/hermes/` | run Hermes setup fresh, stop it, overlay these files into `~/.local/share/hermes/`, restart |
| Steam library (2.2T) | — | redownloads, skip |
| `~/archive/arcade` (223G) | — | skipped per your call, redownload/re-rip |
| `~/archive/monero` (274G blockchain) | — | resyncs from the network, skip |
| music (`~/archive/music`, 360G) | your phone | separate transfer, not in this tar |
| everything else under `~/archive/*` (knowledge, media, pics_camera, roms, wallpaper, games) | not backed up | still lives on p1's disks — if the install wipes them, copy it over before wiping; if it's a separate partition/mount, just keep it mounted |

## Order of operations on the new NixOS install

1. **Boot the new install**, get network + a user shell.
2. **Pull the state tar from sarten** (needs sarten reachable, no SSH key required since you're pulling as root there — or scp as your own user if sarten has your pubkey):
   ```
   scp root@192.168.1.135:/root/backups/p1-state/p1_state_backup_20261026.tar.gz /tmp/
   tar -xzf /tmp/p1_state_backup_20261026.tar.gz -C ~
   ```
3. **Fix permissions** (tar doesn't always preserve these across users/distros):
   ```
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/*
   ```
4. **Clone the repos** (SSH key is now in place):
   ```
   mkdir -p ~/git && cd ~/git
   for r in dots notes sakuhin auth sarten tidal-daemon study openhand rea resume-latex; do
     git clone git@gitlab.com:asynthe/$r.git
   done
   ```
5. **Build the system** from the flake:
   ```
   cd ~/git/dots
   nix flake check .
   sudo nixos-rebuild switch --flake .#p1
   ```
6. **Symlink dotfiles**:
   ```
   ~/git/dots/scripts/bootstrap.sh        # idempotent, re-run is safe
   ~/git/dots/scripts/home_setup.sh --apply
   ```
7. **Hermes**: run its normal fresh-install/setup flow first (gets `tools/`,
   `installs/`, `hermes-agent/` back — those were deliberately NOT in the state
   tar, they're just reinstalled binaries). Then:
   ```
   systemctl --user stop hermes-gateway   # or whatever unit setup created
   # overlay the restored state (already sitting in ~/.local/share/hermes/ from step 2)
   # — just confirm setup didn't overwrite config.yaml/.env/auth.json/state.db etc,
   #   re-copy from the extracted tar if it did
   systemctl --user start hermes-gateway
   ```
8. **Re-point remotes to both hosts** (if any repo only has `origin`):
   ```
   ~/git/dots/scripts/set_remotes.sh --apply
   ```
9. **Sanity pass**: `~/git/dots/scripts/sync_repos.sh -n` (dry run — pulls, flags
   anything that needs attention: missing CLAUDE.md, nested .claude dirs, etc).

## Leftover on sarten

The state tar stays at `/root/backups/p1-state/` on sarten — delete it once
the new system is confirmed working, or keep it as a cold backup.
