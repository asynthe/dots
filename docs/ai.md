# AI tooling

Hermes runs as a NixOS service. Claude Code, Codex and OpenCode are plain CLIs.
Each tool is its own aspect under `nix/modules/ai/`.

## Hermes

`nix/modules/ai/hermes.nix` wraps the upstream `hermes-agent` NixOS module.

| option | default | meaning |
| --- | --- | --- |
| `sys.hermes.model` | `claude-sonnet-5` | default model id; the provider comes from `config.yaml` |
| `sys.hermes.env` | Claude token + Signal | env var -> sops key path; `{}` leaves auth to `hermes auth` |
| `sys.hermes.signal` | `true` | signal-cli HTTP daemon on `127.0.0.1:8080` |
| `sys.hermes.dashboard` | `false` | browser admin panel and `/api` sockets |
| `sys.hermes.bind` | `127.0.0.1` | any address other than loopback turns on the dashboard's auth |
| `sys.hermes.waitForHost` | `false` | wait until `bind` resolves (for tailscale names) |

The secrets live in `secrets/secrets.yaml` under `hermes/`. The Signal numbers
are in sops too, not in the plain environment. If `SIGNAL_ALLOWED_USERS` is
unset, anyone can DM the bot.

State lives in `/var/lib/hermes`, which is persisted when impermanence is on.
Admins are in the `hermes` group.

### Signal: first run

```sh
sudo -u hermes signal-cli --config /var/lib/hermes/signal-cli link -n hermes
```

Scan the QR code from the phone (Settings -> Linked devices).

### Copilot key

The Copilot key toggles a Hermes terminal on a scratchpad. See
`docs/hyprland.md`.
