# Darwin

`nix/darwin/` is the macOS half of the same dendritic tree described in
[DENDRITIC.md](DENDRITIC.md), for the M2 MacBook (`m2`). Same registry, same
rule — one aspect, one name, a host imports what it wants — just a different
class: `flake.modules.darwin.<name>` instead of `flake.modules.nixos.<name>`,
built by `nix-darwin.lib.darwinSystem` instead of `nixpkgs.lib.nixosSystem`.
`nix/flake/darwin-hosts.nix` finds every `host-*` name in that class the same
way `nix/flake/nixos-hosts.nix` does for NixOS.

```
nix/darwin/
  options.nix        sys.user -- the one darwin-side sys.* option, so far
  base/
    core.nix          nix.enable = false, primaryUser, zsh
    auth.nix          reads auth.nix's keys, writes authorized_keys, enables sshd
    homebrew.nix      the homebrew module -- casks that were already installed by hand
    cli.nix           same list as NixOS' cli aspect, minus what doesn't apply here
  dev/
    tools.nix         flake.modules.darwin.neovim -- same tool list as NixOS' neovim aspect
    database.nix      flake.modules.darwin.database -- CLI half of NixOS' database aspect
nix/hosts/m2/          the MacBook -- flake.modules.darwin.host-m2
```

There is no `nix/darwin/profiles/` yet. [DENDRITIC.md's "Roles"
section](DENDRITIC.md#roles) already makes the call: bundling aspects into a
profile pays off at a second host, not before, and there is exactly one Mac.

## Why `nix.enable = false`

The Nix daemon on `m2` came from the official installer, not nix-darwin.
`nix.enable = false` in `core` tells nix-darwin to leave `/etc/nix/nix.conf`
and the daemon alone rather than fight the installer over ownership — the
usual failure mode is nix-darwin silently reverting settings (like
`experimental-features`) the installer already set. It also means
`nix.settings.*` in this tree would be dead weight: nothing here should set
it, since nix-darwin won't render it either.

## `auth.nix`, but only the keys

`auth.nix` is a multi-account, password-and-groups model built for NixOS'
`users.users` — most of that (`admin`, `passwordKey`, `groups`) has nothing to
attach to here, since nix-darwin doesn't create accounts at all;
`system.primaryUser` just names an existing macOS account, and `m2` has
exactly one (`meow`). So `sys.user` is a plain required string set directly on
the host, not derived from `sys.admins` the way NixOS's default is.

What *does* generalize is `keys`: `nix/darwin/base/auth.nix` reads the same
root `auth.nix`, takes `people.${sys.user}.keys`, and on every activation
rewrites `/Users/<user>/.ssh/authorized_keys` from that list and turns on
Remote Login (`services.openssh.enable = true`, which is nix-darwin's wrapper
around `launchctl bootstrap system/com.openssh.sshd` — not a NixOS-style
sshd). Add or revoke a device the same way as on `p1`: edit `auth.nix`,
`darwin-rebuild switch`.

**Every device in `meow.keys` can already log into `m2`** once that switch
happens — `s24`'s existing entry works with no new key. The other direction
(`m2` → `p1`, `p1` → `m2`) needs each host to carry its own identity keypair,
also listed under `meow.keys`. `m2`'s entry (labelled `macbook`) is its
existing GitHub/GitLab key, reused on request — `docs/AUTH.md` recommends a
dedicated key instead ("one private key that both pushes to GitHub and opens
a machine makes a single theft into both"); this was a deliberate exception,
not the default going forward. `p1` needs the same treatment before it can
reach `m2`:

```bash
# on p1
ssh-keygen -t ed25519 -C p1 -f ~/.ssh/id_ed25519_host
cat ~/.ssh/id_ed25519_host.pub   # paste into auth.nix's meow.keys here
```

## Homebrew

`homebrew.enable = true`, but nix-darwin does not install Homebrew itself —
`https://brew.sh`'s installer has to run once, by hand, before the first
`darwin-rebuild switch`. `taps`/`brews` are empty; add CLI tools nixpkgs
doesn't package well on darwin there as they come up.

`casks` currently just mirrors `brew list --cask` from before this flake
existed — `claude-code firefox ghostty mullvad-vpn tailscale-app`. Since the
list matches exactly what's on the machine, `onActivation.cleanup` is safe to
flip to `"zap"` any time — it's a no-op today, and starts pruning the day
something gets `brew install`ed outside this file. Left as `"none"` until
that declarative-only workflow is actually wanted, since `"zap"` uninstalls
anything installed but unlisted.

## Tailscale

`m2` joins the same tailnet as `p1` via the `tailscale-app` cask (a GUI app,
not a NixOS-style `services.tailscale` unit — nix-darwin has no declarative
tailscaled management, and the app is the officially supported path on
macOS; the plain `tailscale` Homebrew formula is CLI/daemon-only and doesn't
fit the same role). Log into it with the same account `p1` uses — after
that, `m2` and `p1` reach each other by tailnet hostname regardless of which
network either is actually on.

## Building and switching

No `nh` wiring yet (unwired options are dead weight — add it if `nh darwin`
support gets used). Plain nix-darwin commands:

```bash
nix build .#darwinConfigurations.m2.config.system.build.toplevel   # check it builds
sudo darwin-rebuild switch --flake .#m2                             # activate
```

`darwin-rebuild` itself comes from the `nix-darwin` input — if it's not on
`PATH` yet, `nix run nix-darwin -- switch --flake .#m2` bootstraps the first
switch, after which `darwin-rebuild` is installed and the plain form works.
