# Secrets

Everything encrypted lives in **one file**: `secrets/secrets.yaml`. There is no
second store and no per-host file — `.sops.yaml` points every `secrets/*.{yaml,json,env}`
at a single age recipient, and `sops.defaultSopsFile` in the `sops` aspect makes
that file the default for every declared secret.

## Layout

sops-nix resolves a secret's `key` as a `/`-separated path into the YAML tree
(`recurseSecretKey` in `sops-install-secrets`), so nesting is free. The leaf must
be a string; intermediate nodes must be maps.

```yaml
users:
    meow: $y$j9T$...          # mkpasswd -m yescrypt
hermes:
    CLAUDE_CODE_OAUTH_TOKEN: sk-ant-oat01-...
```

Grouping by concern is what keeps one file readable as it grows. A second login
is a new leaf under `users:` plus one secret declaration — no restructuring.

## Where the tree touches it

| file | what it declares |
| --- | --- |
| `.sops.yaml` | creation rule → the age recipient |
| `nix/nixos/security.nix` | the `sops` aspect: `defaultSopsFile`, `sys.sops.ageKeyFile`, `user-password` |
| `nix/nixos/ai.nix` | the `hermes` aspect: one secret per `sys.hermes.env` entry, plus the `hermes-env` template |
| `nix/nixos/impermanence.nix` | persists `/etc/ssh` host keys, which sops-nix can also use as an identity |

`sops` itself is in the import list of both `nix/hosts/p1` and `nix/hosts/sarten`.

## Two decrypt paths

`neededForUsers = true` (the user password) decrypts into
`/run/secrets-for-users` during the `users` activation step, early enough to set
`hashedPasswordFile`. Everything else lands in `/run/secrets`, and rendered
templates in `/run/secrets/rendered`. Both are tmpfs — nothing decrypted is
written to disk.

The private identity is root-owned and outside `/home`, because activation
unlocks passwords before `/home` is guaranteed mounted. `sys.sops.ageKeyFile`
says where it lives: the default `/persist/secrets/age-keys.txt` survives the
impermanence rollback because `/persist` is its own btrfs subvolume, and `sarten`
— which has no impermanence and therefore no `/persist` — moves it to
`/var/lib/sops/age-keys.txt`.

## Adding a host

Two ways in, and this repo takes the second.

sops encrypts per recipient, so a host with its *own* age key needs that public
key added to `.sops.yaml` and the file re-encrypted with
`sops updatekeys secrets/secrets.yaml` — until then the host can build but not
decrypt.

`sarten` instead reuses the identity `p1` already has: same private key, copied
to the path `sys.sops.ageKeyFile` names, no new recipient and no re-encryption.
That is one key to rotate rather than two, at the cost of one machine's
compromise being both machines'. For a host installed by nixos-anywhere the copy
is a `--extra-files` staging directory — the full sequence is in
[SARTEN.md](SARTEN.md).

Either way the identity has to be in place *before* the first activation:
`user-password` is `neededForUsers`, and sops-nix fails the activation on a
secret it cannot decrypt.
