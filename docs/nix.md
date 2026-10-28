# Nix layout

The flake uses the dendritic pattern: every `.nix` file under `nix/` is a
flake-parts module. `import-tree` loads all of them, so there is no import
list to maintain. A file declares one aspect (a NixOS module) under
`flake.modules.nixos.<name>`, and hosts pick the aspects they want by name.

```
flake.nix               inputs, plus mkFlake over import-tree ./nix
nix/
  flake/                flake-level parts: systems, hosts, checks, devshell, formatter
  modules/<category>/   one aspect per file, named after the aspect
  hosts/<host>/         host aspect (host-<name>) plus its hardware and disko
```

Files and folders starting with `_` are skipped by import-tree. That's how
drafts like `hosts/p1/_disko-dualboot.nix` stay in the repo unimported.

## Conventions

- One aspect per file. `nix/modules/dev/postgres-local.nix` declares
  `flake.modules.nixos.postgres-local` and nothing else.
- Repo-wide options live under `sys.*`, declared in `nix/modules/options.nix`
  (plus the aspect that owns them, e.g. `sys.hermes`, `sys.share`).
- Persistence goes next to the service that needs it, guarded by
  `lib.mkIf config.sys.impermanence.enable`.
- Groups go on admins with `users.users = lib.genAttrs config.sys.admins ...`,
  never on a hardcoded user name.
- Accounts come from `auth.nix` at the repo root; `nix/modules/base/auth.nix`
  turns them into users and sops password secrets.

## Commands

```sh
nix fmt                       # nixfmt over the whole tree
nix flake check               # formatting + every host's toplevel
nh os switch                  # rebuild (sys.flake points nh at this repo)
nix develop                   # sops, age, ssh-to-age, nom
```

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
