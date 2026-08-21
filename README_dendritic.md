# The dendritic layout

This flake is built on the [dendritic pattern]. Every `.nix` file under `nix/`
is a **flake-parts module**, auto-imported by [`import-tree`]. Nothing is ever
imported by hand — there is no `imports = [ ... ]` list to keep in sync anywhere
in this repo. Each file registers one or more *aspects* into
`flake.modules.nixos.<name>`, and a host is a list of aspects.

The previous non-dendritic tree is archived in `nix_old/`.

## Layout

```
flake.nix                     the only entry point: mkFlake (import-tree ./nix)
nix/modules/
  flake/
    registry.nix              turns on flake.modules.<class>.<name>
    hosts.nix                 every `host-*` aspect becomes a nixosConfiguration
  nixos/                      the aspect library — one domain per file
  hosts/p1/                   the Thinkpad
nix_old/                      the previous config, kept for reference
```

## Two rules

1. **No `enable` options.** A host turns a feature on by importing its aspect.
   The old `sys.modules.<name>.enable` layer is gone; `nix/modules/hosts/p1/default.nix`
   is now the single readable list of what this machine is.
2. **Options are only for values that differ between machines** — `sys.user`,
   `sys.gpu.*`, `sys.impermanence.*`, `sys.ssh.authorizedKeys`. They live in
   `nix/modules/nixos/options.nix`.

Several files may write to the same aspect name and the definitions merge, so
`core` is assembled from `options.nix` and `core.nix` together.

## Adding a host

Create `nix/modules/hosts/<name>/default.nix`:

```nix
{ config, ... }:
{
    flake.modules.nixos.host-mini = { ... }: {
        imports = with config.flake.modules.nixos; [
            core cli
            boot network ssh
            # ... whatever this machine is
        ];

        networking.hostName = "mini";
        system.stateVersion = "25.05";
        sys.user = "meow";
    };
}
```

`git add` it and `nixosConfigurations.mini` exists. No other file changes.

## Rebuilding

From the repo root:

```bash
sudo nixos-rebuild switch --flake .#p1
# or
nh os switch .
```

`--flake` is required — `nixos-rebuild switch '.#p1'` is rejected as an
unrecognized argument. New files must be `git add`ed before Nix can see them;
flakes ignore untracked files.

## Parity with `nix_old/`

The generated system was diffed against the old tree on the same locked inputs:
identical 404-package set, identical `/etc`, systemd units, dbus config and
impermanence list, and `nix store diff-closures` reports no version changes.

[dendritic pattern]: https://github.com/mightyiam/dendritic
[`import-tree`]: https://github.com/vic/import-tree
