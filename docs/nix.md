# Nix layout

The flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic).
Every `.nix` file under `nix/` is a flake-parts module, and `import-tree`
loads all of them, so there is no import list to maintain. Each file defines
exactly one aspect (a NixOS module) under `flake.modules.nixos.<name>`. Hosts
pick aspects by name, mostly through profiles.

```
flake.nix                  inputs, plus mkFlake over import-tree ./nix
auth.nix                   people: admin flag, ssh keys, sops password key
nix/
  flake/                   flake-level parts
    systems.nix            supported systems, enables flake.modules
    hosts.nix              every host-<name> aspect becomes nixosConfigurations.<name>
    checks.nix             host toplevels + formatting
    formatter.nix          `nix fmt` (nixfmt-tree)
    devshell.nix           sops, age, ssh-to-age, nom
  modules/
    options.nix            the sys.* options every aspect builds on
    profiles/              bundles of aspects: base, desktop, dev, ai, gaming, ...
    base/ desktop/ dev/ ai/ apps/ games/ hardware/ net/
  hosts/p1/                host-p1 aspect, hardware, disko
```

Files and folders starting with `_` are skipped by import-tree. That's how
drafts like `hosts/p1/_disko-dualboot.nix` stay in the repo unimported.

## Conventions

- One aspect per file, named after the aspect: `modules/dev/postgres-local.nix`
  declares `flake.modules.nixos.postgres-local` and nothing else.
- Hosts import profiles plus the hardware-specific aspects. Profiles only
  import aspects; they never set options.
- Formatting is nixfmt (RFC 166). `nix fmt` applies it and `nix flake check`
  fails on any unformatted file. deadnix and statix stay clean, and
  `statix.toml` turns off `repeated_keys` because `boot.x = ...; boot.y = ...;`
  reads better in host files.

### Shared options

Aspects never touch `environment.persistence` or other users directly. They
append to options declared in `modules/options.nix`:

| option | effect |
| --- | --- |
| `sys.persist.directories` / `files` | kept across reboots when the host imports `impermanence` |
| `sys.adminGroups` | extra groups for every admin in `auth.nix` |
| `sys.user` | the account the seat autologins into |
| `sys.flake` | path to this repo, used by nh |

That keeps impermanence opt-in per host, and the user list lives in exactly
one place.

## Commands

```sh
nix fmt                       # format every .nix file
nix flake check               # formatting + evaluate/build every host
nh os switch                  # rebuild the current host
nix develop                   # secrets tooling
```

## Adding things

- **Package or service:** create `modules/<category>/<name>.nix` declaring
  `flake.modules.nixos.<name>`, then add `<name>` to a profile or a host.
- **Host:** create `hosts/<name>/default.nix` declaring
  `flake.modules.nixos.host-<name>`. `flake/hosts.nix` picks it up and so does
  `nix flake check`.

## systemd-boot titles

`base/boot.nix` rewrites the entry titles to `NixOS Linux (<kernel>) Gen <n>`
after every install. Only the `title` line changes, so `version` and
`sort-key` keep the ordering. Any ` [profile]` or ` (specialisation)` suffix
is kept. Entries are content-hashed, so the builder rewrites the edited ones
on every switch and the hook re-titles them each time. That's harmless churn
on the ESP.

## dbt

`dev/dbt.nix` builds dbt on Python 3.13, because dbt-semantic-interfaces
doesn't support 3.14. Some pins are stale and get relaxed: dbt-common pins
`pathspec<1.1`, and dbt-core and dbt-semantic-interfaces pin `click<8.4`.
Adapters go through `withAdapters`, because they are namespace packages and
collide on `dbt/__init__.py` in a plain `buildEnv`. Only `bin/dbt` is exposed,
so the env's `python3` doesn't shadow the system one.
