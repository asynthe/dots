# Wazuh

The SIEM on `sarten`. It is the one service on this box that a rebuild cannot
reproduce, and this file records why, and what was done by hand to get it
running.

## The split

Wazuh has no nixpkgs package and no NixOS module, and upstream ships a
three-container stack — manager, indexer (OpenSearch), dashboard — with its own
certificate authority and six config files. Translating that YAML into Nix would
mean maintaining the translation forever, so the compose file is used exactly as
upstream publishes it and `nix/nixos/server/wazuh.nix` owns only three things:

- `boot.kernel.sysctl."vm.max_map_count" = 262144` — the indexer is OpenSearch
  and refuses to start below this.
- a tmpfiles rule creating `/srv/wazuh` as `0750 root root`.
- a `oneshot` + `RemainAfterExit` unit whose whole body is `docker-compose up -d`
  in `/srv/wazuh/single-node`, with `down` as `ExecStop`.

Everything else — the stack definition, the version pin, the certificates — lives
in `/srv/wazuh`, on the `tank/wazuh` dataset, outside the flake. The unit carries
`ConditionPathExists` on the compose file so a host without that checkout skips
the unit instead of booting with a unit it cannot fix itself.

The aspect names no version. Upgrading Wazuh is editing the compose file on the
box, not a rebuild.

## What went wrong

The checkout started as a single hand-placed `docker-compose.yml` from
**5.0.0-beta5**, with none of the certificate material it references. Docker
does not fail on a missing bind-mount source — it creates it as a directory — so
all five cert paths became empty directories and the indexer died on:

```
Caused by: org.opensearch.OpenSearchException:
  /usr/share/wazuh-indexer/config/certs/root-ca.pem - is a directory
```

with the manager and dashboard stuck in `Created`, blocked on
`depends_on: service_healthy`.

The certificates were always a manual step. The problem is that on 5.0.0-beta5
there is no way to perform it: upstream removed `generate-indexer-certs.yml` from
`single-node/` at that tag, and the 5.x docs replace it with two downloads from
`packages.wazuh.com/5.0/` — `wazuh-certs-tool-5.0.0-1.sh` and
`config-5.0.0-1.yml` — which both return **HTTP 403**. Wazuh has not published
them. There is no working certificate path on that version.

## The fix: pin to 4.14.7

`v4.14.7` is the current stable line and is entirely self-contained: it ships
`generate-indexer-certs.yml`, `config/certs.yml` and the
`wazuh/wazuh-certs-generator:0.0.4` image, so the certs are generated from the
checkout with no external downloads.

Running it inside an Incus container was considered and rejected. It does not
solve the certificate problem — you would still generate them by hand — and the
alternative to Docker-in-Incus is a native `apt install` on a Debian you then
maintain, which turns one pinned YAML file into a hand-managed pet. Incus becomes
the right answer only when the goal is `incus snapshot` before version bumps, or
moving Wazuh off the host's 443/1514/1515/55000 onto its own address; both are
deliberate moves, not workarounds.

## Steps taken

The checkout was staged from a laptop rather than fetched on the box, so nothing
depended on the server's network mid-run.

```bash
# on the laptop: fetch the tag and keep only single-node/
curl -sfL https://github.com/wazuh/wazuh-docker/archive/refs/tags/v4.14.7.tar.gz | tar xz
rsync -a wazuh-docker-4.14.7/single-node/ meow@sarten:/home/meow/wazuh-4.14.7/
```

Then, as root on the box:

```bash
systemctl stop wazuh.service
docker rm -f single-node-wazuh.dashboard single-node-wazuh.manager single-node-wazuh.indexer

# the beta5 volumes never initialised, so there was nothing to preserve
docker volume ls --format '{{.Name}}' | grep '^single-node' | xargs -r docker volume rm

rm -rf /srv/wazuh/single-node
mkdir -p /srv/wazuh/single-node
cp -a /home/meow/wazuh-4.14.7/. /srv/wazuh/single-node/
chown -R root:root /srv/wazuh/single-node

cd /srv/wazuh/single-node
docker compose -f generate-indexer-certs.yml run --rm generator

systemctl start wazuh.service
```

The generator writes into `config/wazuh_indexer_ssl_certs/` — a flat directory in
4.14.x, unlike the per-node layout beta5 expected — which is why the whole
checkout has to be replaced rather than patched. First start pulls roughly 2 GB
of images and the indexer takes a minute or two to build its indices;
`TimeoutStartSec` is 1800 for that reason.

## Access

The dashboard is on **443**, and `sys.wazuh.openFirewall` is `false`, so it is
reachable over the tailnet only:

```
https://sarten
```

`/` redirects to `/app/login`, and after login to `/app/wz-home` — that is
`uiSettings.overrides.defaultRoute` in
`config/wazuh_dashboard/opensearch_dashboards.yml`. The long unreadable query
strings after that are rison-encoded app state, normal for anything built on
OpenSearch Dashboards. The certificate is signed by the root CA the generator
made, so expect a browser warning.

Upstream's stock credentials, published in the compose file and
`config/wazuh_indexer/internal_users.yml`. Change them.

| Account | Password | Used for |
| --- | --- | --- |
| `admin` | `SecretPassword` | the dashboard login |
| `kibanaserver` | `kibanaserver` | dashboard → indexer |
| `wazuh-wui` | `MyS3cr37P450r.*-` | dashboard → manager API on 55000 |

Holding port 443 means anything else wanting plain HTTPS on this box needs a
different port, or Wazuh needs moving via `sys.wazuh.dashboardPort`.

## What it can currently see: itself

`agent_control -l` lists one agent — `000, wazuh.manager, 127.0.0.1` — which is
the manager monitoring its own container. The manager has no host paths bound in
beyond its certs and `ossec.conf`, no `/var/run/docker.sock`, its own PID and
network namespaces, and is not privileged. It therefore sees nothing of the
NixOS host, the other Docker containers, or the Incus instances.

Extending it means one of:

- **the host** — a `wazuh-agent` running on NixOS itself, enrolled to the manager
  on 1514/1515. There is no `wazuh-agent` in nixpkgs, so this needs packaging
  first.
- **Docker** — the `docker-listener` wodle, which needs `/var/run/docker.sock`
  mounted into the manager. Gives container lifecycle events, not file integrity
  inside them.
- **Incus instances** — an agent inside each one, exactly as for any other host.

## Reporting in without an agent

There is no `wazuh-agent` in nixpkgs — `ossec-agent` and `ossec-server` were
removed on 2025-11-08 for lack of maintenance — so the NixOS hosts report by
forwarding their journals to the manager's syslog listener instead.

Two halves. On the manager, a second `<remote>` block in
`config/wazuh_cluster/wazuh_manager.conf`, since the stock config listens only
for agents on 1514:

```xml
<remote>
  <connection>syslog</connection>
  <port>514</port>
  <protocol>udp</protocol>
  <allowed-ips>172.18.0.0/16</allowed-ips>
</remote>
```

On each host, the `wazuh-syslog` aspect: rsyslog with `imjournal` reading the
journal and `omfwd` forwarding it, `defaultConfig` blanked so it does not also
start writing `/var/log/messages` beside journald. `sys.wazuh.syslogTarget`
defaults to `sarten`. The unit is `syslog.service`, not `rsyslogd`.

Verified working — failed SSH logins on `sarten` and failed `sudo` on `p1` both
fire rules 2501 and 2504.

Two things this does not give you. It is **UDP**, because 514/udp is the only one
the compose file publishes, so a host off the tailnet drops its logs silently.
And it is logs only: no file integrity monitoring, no configuration assessment,
no software inventory, no active response. Those need a real agent, which on
NixOS would mean packaging one — see [docs/LAB.md](LAB.md) for why the lab
instances are the better home for that.

The `<allowed-ips>` line is not the security boundary. Docker's userland proxy
rewrites the source address, so every event arrives as `172.18.0.1` whoever sent
it. The NixOS firewall is the actual control: 514/udp is not in
`allowedUDPPorts`, `openFirewall` is false, and `tailscale0` is trusted, so only
tailnet peers reach it. Per-host attribution is unaffected — Wazuh reads the
hostname from the message, not the packet.

## Changing the admin password

`admin` is `reserved: true` in `internal_users.yml`, so the dashboard and the API
both refuse with `Resource 'admin' is reserved` — reserved users are file-managed
only. Generate a bcrypt hash with the indexer's `hash.sh`, replace the hash in
`config/wazuh_indexer/internal_users.yml`, then push it into the security index:

```bash
docker exec -e JAVA_HOME=/usr/share/wazuh-indexer/jdk single-node-wazuh.indexer-1 \
  bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
    -f /usr/share/wazuh-indexer/config/opensearch-security/internal_users.yml \
    -t internalusers -icl -nhnv \
    -cacert /usr/share/wazuh-indexer/config/certs/root-ca.pem \
    -cert   /usr/share/wazuh-indexer/config/certs/admin.pem \
    -key    /usr/share/wazuh-indexer/config/certs/admin-key.pem \
    -h localhost -p 9200
```

Both `INDEXER_PASSWORD=` lines in `docker-compose.yml` have to change too — the
manager's filebeat and the dashboard both authenticate to the indexer as `admin`,
so changing only the hash breaks ingestion silently. Avoid `$` in the passphrase:
Compose interpolates it in an environment value.

## Rebuilding from scratch

`/srv/wazuh` is on `tank/wazuh`. If the pool survives, nothing here needs doing
again. If it does not, repeat *Steps taken* — the checkout is reproducible from
the tag, and the certificates are regenerated rather than restored.
