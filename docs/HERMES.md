# `hermes` aspect

Hermes Agent (Nous Research), wired as a shared aspect that both `p1` and
`sarten` import. Defined in `ai.nix`; upstream module comes from the
`hermes-agent` flake input.

## What it is

An API client, not a model runtime. Nothing local has to be running — it needs
exactly one provider credential. The `anthropic` provider profile accepts
`ANTHROPIC_API_KEY`, `ANTHROPIC_TOKEN` or `CLAUDE_CODE_OAUTH_TOKEN`, so a token
from `claude setup-token` works directly. Pair with the `ollama` aspect only if
you actually want local inference.

## Per-host knobs

| option | default | why it varies |
| --- | --- | --- |
| `sys.hermes.model` | `anthropic/claude-opus-4.6` | `<provider>/<model>` |
| `sys.hermes.env` | `{ CLAUDE_CODE_OAUTH_TOKEN = "hermes/CLAUDE_CODE_OAUTH_TOKEN"; }` | env var → sops key path; `{}` skips sops entirely |
| `sys.hermes.dashboard` | `false` | `sarten` wants the admin panel, laptop does not |
| `sys.hermes.bind` | `127.0.0.1` | `sarten` binds its tailscale name |
| `sys.hermes.waitForHost` | `false` | poll until `bind` resolves — tailscaled loses the boot race otherwise |

`p1` takes the defaults. `sarten` sets `dashboard = true`, `bind = "sarten"`,
`waitForHost = true`.

## The secret

`environmentFiles` gets dotenv *contents*, not a single value — one `KEY=value`
per line. Rather than storing that blob verbatim, the aspect keeps each variable
as its own nested key in `secrets/secrets.yaml` and assembles the dotenv with a
sops template:

```yaml
hermes:
    CLAUDE_CODE_OAUTH_TOKEN: sk-ant-oat01-...
```

`sys.hermes.env` maps env var name → sops key path. Each entry becomes a secret
named `hermes-<VAR>`, and `sops.templates.hermes-env` interpolates their
placeholders into `/run/secrets/rendered/hermes-env`, which is what the service
actually reads. Adding a provider is one line:

```nix
sys.hermes.env.OPENAI_API_KEY = "hermes/OPENAI_API_KEY";
```

Until those keys exist, activation fails: sops-nix errors on a declared secret
that is missing from the file. To rebuild before then, set
`sys.hermes.env = {}` on the host and authenticate at runtime with `hermes auth`
instead — the template and the secrets both disappear with it.

The option type is `str`, not `path`, on purpose. A Nix path literal would copy
the secret into `/nix/store`, which is world-readable.

Ordering is safe: hermes' activation script declares
`stringAfter [ "users" "setupSecrets" ]`, so the template is rendered before
anything copies it into `$HERMES_HOME/.env`.

## Running it

`HERMES_HOME=/var/lib/hermes/.hermes` is exported system-wide from
`/etc/set-environment`, and the dir is `2770 hermes:hermes` — so an interactive
shell needs the `hermes` group, which only applies after a fresh login.

```
hermes status              # env, which API keys resolved, auth providers
hermes chat                # interactive session
hermes -z "..."            # one-shot prompt, for scripts
hermes doctor              # diagnostics
```

The `hermes-agent` unit is the *gateway*, not the CLI: it bridges messaging
platforms (Telegram, WhatsApp, Slack) and idles with "No messaging platforms
enabled" until one is configured. The CLI does not need it running.

`hermes model` switches the model for the session; `sys.hermes.model` sets the
declarative default. Setting `sys.hermes.dashboard = true` adds the separate
`hermes-backend` unit serving the admin panel on `sys.hermes.bind`.

## State lives in the service dir

`addToSystemPackages = true` puts `hermes` on PATH *and* exports
`HERMES_HOME=/var/lib/hermes/.hermes` system-wide, so an interactive shell and
the daemon share sessions, skills and cron. That dir is `2770 hermes:hermes`,
which is why the aspect adds `sys.user` to the `hermes` group — log out and back
in after the first switch or you get EACCES.

Under impermanence, `/var/lib/hermes` is persisted; without it every reboot
wipes the sessions.

## The daemon is the messaging gateway

The unit's `ExecStart` is `hermes gateway` — the Discord/Telegram/Signal bridge,
not the terminal agent. For CLI-only use it is dead weight; adapters that are
not configured log warnings rather than erroring, but confirm with
`systemctl status hermes-agent` after the first switch. If it crash-loops, drop
`services.hermes-agent.enable` and take
`inputs.hermes-agent.packages.<system>.default` into `environment.systemPackages`.

Binding `dashboard` to anything but loopback turns on its auth gate. The module
mints a fresh session token per start unless `backend.sessionTokenFile` points
at one — add a second sops secret when the server needs a stable token.

## Boot race on the state dir

`/var/lib/hermes` is persisted with `user = "hermes"; group = "hermes"; mode = "2770"`
rather than as a bare string. Impermanence would otherwise create it `root:root
0755`, and the unit's `WorkingDirectory` fails with `Failed at step CHDIR` until
hermes' own activation script catches up — three restarts before it settles.

## First build is expensive

~1234 derivations built locally and ~970 MiB fetched (3.4 GiB unpacked): the
Python closure comes through uv2nix and the npm/Electron tarballs are not in
the public cache. Later rebuilds are cheap.

## Running it

```sh
hermes            # bare invocation drops into the interactive chat TUI
hermes doctor     # provider/auth health check
hermes model      # see or switch the active model
hermes status
```
