# Managing this config

This flake is built on the [dendritic pattern]. Every `.nix` file under `nix/`
is a **flake-parts module**, auto-imported by [`import-tree`]. Nothing is ever
imported by hand — there is no `imports = [ ... ]` list to keep in sync anywhere
in this repo.

The previous non-dendritic tree has been removed; it lives in history at
`1735865` if you ever need to look something up.

## Layout

```
flake.nix                     the only entry point: mkFlake (import-tree ./nix)
auth.nix                      who may log in, and with which key -- data, not a module
nix/
  flake/
    registry.nix              turns on flake.modules.<class>.<name>
    nixos-hosts.nix           every `host-*` aspect in the nixos class becomes a nixosConfiguration
    darwin-hosts.nix          every `host-*` aspect in the darwin class becomes a darwinConfiguration
    checks.nix                `nix flake check` builds every host, either class
    devshell.nix              sops, age, ssh-to-age, nom
  nixos/
    options.nix               values that differ between machines
    base/                     what any machine gets: core cli auth security ssh net boot
    profiles/                 role bundles; a host names one instead of a dozen aspects
    desktop/ dev/ hardware/ net/   the rest of the aspect library, one domain per file
  darwin/                     the macOS half of the tree, see DARWIN.md
    options.nix / base/       same shape as nixos/, class `darwin` instead of `nixos`
  hosts/p1/                   the Thinkpad, class nixos
  hosts/m2/                   the MacBook, class darwin
assets/                       images the config points at
secrets/                      sops-encrypted, see .sops.yaml
```

`nix/nixos/` and `nix/darwin/` are separate classes in the same registry, not
two flakes glued together — see [DARWIN.md](DARWIN.md) for what's genuinely
different about the macOS side (no `auth.nix`, no `nix.enable`, Homebrew).

Same shape as `~/git/flakes`, so a file is in the same place in both repos.
`profile-laptop` is the layer that pays off at the second machine: it bundles
what any of mine would want — core, cli, auth, sops, boot, network, ssh, the
editor — and `nix/hosts/p1` then lists only what makes it *this* laptop.

`auth.nix` is the one `.nix` file outside `nix/`, and that is deliberate:
import-tree would otherwise pick it up as a flake-parts module. The aspect that
reads it is `nix/nixos/base/auth.nix` — see [AUTH.md](AUTH.md).

## The mental model

Three facts explain everything else:

1. Every file under `nix/` is a flake-parts module, auto-imported.
2. Each file writes into `flake.modules.nixos.<name>` — the registry. That is
   all an *aspect* is: a named NixOS module sitting in an attrset.
3. A host is a list of names pulled back out of that registry.

So there are only two operations: **put something in the registry**, and
**name it in a host**.

Two consequences worth internalising:

- **No `enable` options.** A host turns a feature on by importing its aspect.
  The old `sys.modules.<name>.enable` layer is gone; the import list in
  `nix/hosts/p1/default.nix` is now the complete, honest answer to
  "what is this machine?"
- **Options are only for values that differ between machines** — `sys.user`,
  `sys.gpu.*`, `sys.impermanence.*`, `sys.ssh.authorizedKeys`. They are all
  declared in `nix/nixos/options.nix`.

---

# Rebuilding

All commands run from the repo root. **`--flake` is required** — a bare
`nixos-rebuild switch '.#p1'` is rejected as an unrecognized argument.

```bash
# 1. Check it builds. No root, no activation. This is the fast feedback loop.
nixos-rebuild build --flake .#p1

# 2. See what would change before committing to it.
nixos-rebuild build --flake .#p1 --diff

# 3. Activate, and add a boot entry.
sudo nixos-rebuild switch --flake .#p1
```

Get in the habit of running `build` before `switch`. It catches every
evaluation and build error without touching the running system.

### The other actions

| command | activates now | boot entry | use when |
| --- | --- | --- | --- |
| `build`  | no  | no  | checking your work |
| `test`   | yes | no  | risky change you want to undo by rebooting |
| `boot`   | no  | yes | kernel change; take effect on next reboot |
| `switch` | yes | yes | the normal case |

`test` is the safety net for anything touching the display stack, GPU drivers,
or the bootloader: if it wedges the session, a reboot returns you to the last
`switch`ed generation.

### With nh

`nh` is installed and `NH_FLAKE` points at this repo, so the short forms work
from anywhere:

```bash
nh os switch      # equivalent to nixos-rebuild switch --flake .#p1
nh os boot
nh os test
```

`nh` shows a package diff by default, which is why it is usually the nicer
front end.

### When it goes wrong

```bash
sudo nixos-rebuild switch --rollback     # previous generation
nixos-rebuild list-generations
```

Or pick an older generation from the systemd-boot menu at boot. The bootloader
keeps 3 generations (`nix/nixos/boot.nix`).

### Before you rebuild

**New files must be `git add`ed.** Nix ignores files git does not know about,
so a new aspect that seems to do nothing is almost always a missing `git add`.
This will bite you more than anything else.

---

# Daily tasks

## Adding a package

Find the aspect that owns it and add the line:

| what | where |
| --- | --- |
| shell tool, every host | `nix/nixos/cli.nix` |
| needs a running Hyprland | the `hyprland` aspect, `nix/nixos/desktop/hyprland.nix` |
| GUI app, any compositor | the `desktop-apps` aspect, `nix/nixos/desktop/apps.nix` |
| terminal emulator | the `terminals` aspect, same file |
| LSP / editor tooling | the `neovim` aspect in `nix/nixos/dev/tools.nix` |
| font, or a tool for fonts | the `fonts` aspect, `nix/nixos/desktop/look.nix` |
| audio mixer / control | the `audio` aspect, `nix/nixos/hardware/peripherals.nix` |
| CLI for a subsystem | that subsystem's own aspect -- `bluetooth`, `boot`, `network` |
| music player, visualiser | the `music` aspect, `nix/nixos/apps.nix` |
| one self-contained app | its own aspect in `nix/nixos/apps.nix` |

Then `nixos-rebuild build --flake .#p1`.

The line that matters is between `hyprland` and `desktop-apps`: **does this
program presuppose a running Hyprland session?** A bar, launcher, notifier or
wallpaper daemon does, so it lives in `hyprland`. A browser or image viewer
does not, so it lives in `desktop-apps` and stays usable on a host that never
starts a compositor. CLI-vs-GUI is not the axis — it never varies per host, so
it cannot help you decide anything.

Anything in `cli.nix` is on **every** host, including a future headless one, so
it has to be defensible there. A tool that only makes sense because some
subsystem is enabled belongs *with* that subsystem, not in `cli.nix` --
`bluetuith` ships with `bluetooth`, `efibootmgr` with `boot`, `impala` with
`network`, `acpi` with `laptop`. Keeping them together means a host that
declines the subsystem also declines its tooling, with nothing to remember.

## Turning a feature off

Delete its name from the import list in `nix/hosts/p1/default.nix`.
Removing `monero` from that list is how you uninstall Monero. Presence in the
list *is* the switch.

## Creating an aspect

Add it to whichever domain file fits — `apps.nix`, `dev/tools.nix`,
`net/services.nix`:

```nix
flake.modules.nixos.obs = { pkgs, ... }: {
    programs.obs-studio.enable = true;
    environment.systemPackages = [ pkgs.obs-cli ];
};
```

Then add `obs` to the host's import list. If it needs a whole new domain, make
a new file — `git add` it and import-tree picks it up with zero registration.

**Aspects merge.** Several files may write to the same aspect name and the
definitions combine. `core` is already built this way: `options.nix` contributes
the option declarations and `core.nix` contributes the config, and they land as
one module. Use this when a feature has parts belonging in different domains.

## Adding a host

Create `nix/hosts/<name>/default.nix`:

```nix
{ config, ... }:
{
    flake.modules.nixos.host-mini = { ... }: {
        imports = with config.flake.modules.nixos; [
            core cli
            boot network ssh tailscale
            # ... whatever this machine is
        ];

        networking.hostName = "mini";
        system.stateVersion = "25.05";
        sys.user = "meow";
    };
}
```

`git add` it and `nixosConfigurations.mini` exists. Nothing else in the repo
changes — `nix/flake/hosts.nix` finds every `host-*` aspect
automatically.

Register the machine's `nixos-generate-config` output as its own aspect, the
way `p1-hardware` is in `nix/hosts/p1/hardware.nix`.

Build it from the laptop with `nixos-rebuild build --flake .#mini`; deploy with
`--target-host`.

---

# Introspection

These answer almost every question you will have.

```bash
# What aspects exist?
nix eval .#modules.nixos --apply builtins.attrNames

# What did the host actually end up with?
nix eval .#nixosConfigurations.p1.config.sys --json | jq

# Where does this setting come from?
nix eval .#nixosConfigurations.p1.options.services.tailscale.enable.definitionsWithLocations \
  --apply 'ds: map (d: d.file) ds'
```

That last one is the important one. The module system records the *aspect name*
alongside the file:

```
"…/nix/nixos/net/vpn.nix, via option flake.modules.nixos.tailscale"
```

It works for merged values too — asking about `services.xserver.videoDrivers`
reports `["nvidia"]` from `nvidia-prime` and `["modesetting"]` from `intel-gpu`
as separate definitions.

---

# Failure modes

**Untracked files are invisible.** See above. `git add` first.

**Typos are undefined variables.** The host list uses
`with config.flake.modules.nixos;`, so a misspelled aspect reads as a variable:

```
error: undefined variable 'tailscal'
```

Clear, but it points at the host file rather than at what you meant.

**Do not read the registry at flake level in a file that also writes to it.**
Inside a host's deferred module (`{ ... }: { imports = with config.flake.modules.nixos; … }`)
the read is lazy and fine — that is why `hosts/p1/default.nix` works. The same
read at the top level of a defining file recurses infinitely.

**Aspects have implicit partners.** `nvidia-prime` needs `intel-gpu` and both
bus IDs; `hyprland-cache` is pointless without `hyprland-flake`;
`star-citizen-cache` without `star-citizen`. The GPU pairing carries an
`assertions` block; when you build a new pairing, add one — it is cheaper than
rediscovering the dependency in six months.

---

# Two hosts

Sharing config between machines needs no new machinery — it is what the registry
already does. An aspect is a named module in `flake.modules.nixos`; a host is a
list of names pulled back out. Shared means *both lists name it*:

```
nix/nixos/ai.nix                 defines  flake.modules.nixos.hermes
nix/nixos/server/jellyfin.nix    defines  flake.modules.nixos.jellyfin

nix/hosts/p1/                    imports  hermes
nix/hosts/sarten/                imports  hermes  jellyfin
```

`hermes` is written once and lands on both. `jellyfin` is named by one host, so
it exists only there. Nothing declares "this is a server module" — being unnamed
by `p1` is the whole mechanism.

## Varying a shared aspect per host

This is the part worth getting right. A shared aspect must not hardcode what
differs between machines, so anything host-specific becomes a `sys.*` option the
aspect reads and the host sets:

```nix
sys.hermes.dashboard   = true;
sys.hermes.bind        = "sarten";
sys.hermes.waitForHost = true;
```

`p1` sets none of these and takes the defaults. The rule from `options.nix` still
holds — declare an option only for values that genuinely differ between machines,
never as a per-feature `enable` flag. Importing the aspect *is* the enable flag.

## Guard host-specific assumptions

An aspect landing on two machines can no longer assume the laptop's environment.
The two that bite:

- **Impermanence.** `p1` wipes `/` on boot, `sarten` does not. Aspects
  persist through `lib.mkIf config.sys.impermanence.enable [ ... ]`, which is
  inert on a host that never enables it.
- **Secrets.** Both hosts read `secrets/secrets.yaml`, but sops decrypts per
  machine. A second host needs its age identity added as a recipient before it
  can read any secret, or activation fails there.

## Roles

Bundling aspects into `base` / `workstation` / `server` roles is possible — a
role is just an aspect whose body is an `imports` list — but with two hosts it
buys less than it costs: the indirection hides which machine gets what, and the
lists have barely converged yet. Add roles when a third host makes the
duplication real, not before.

---

# Parity with the pre-dendritic tree

The generated system was diffed against the old tree on identical locked
inputs: identical 404-package set, identical `/etc`, systemd units, dbus config
and impermanence list, and `nix store diff-closures` reported no version
changes. On that evidence the old tree was deleted; `git show 1735865:nix_old/...`
still reaches any file in it. Generation rollback is the real recovery path
anyway.

[dendritic pattern]: https://github.com/mightyiam/dendritic
[`import-tree`]: https://github.com/vic/import-tree
