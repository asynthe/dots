# SOC lab

What `sarten` is being built into: somewhere to generate attacks, detect them,
and learn what the detection actually looked like. This file is the plan and the
running assessment — it records what exists, what the hardware can carry, and
what to add next, so the work can be picked up cold.

## What exists now

| Piece | State |
| --- | --- |
| Wazuh 4.14.7 | manager, indexer, dashboard on Docker; `https://sarten` |
| Syslog pipeline | `wazuh-syslog` aspect on `p1` and `sarten`; both reporting |
| Incus | zfs pool on `tank/incus`, `incusbr0` + `labbr0`, no instances yet |
| Attacker box | `p1` with `soc-tools` and `pentest` |
| Transport | tailnet; nothing exposed on the LAN |

Verified working: failed SSH logins on `sarten` and failed `sudo` on `p1` both
reach the manager and fire rules — 2501 (authentication failure, level 5) and
2504 (illegal root login, level 9, MITRE `T1548.003`).

See [docs/WAZUH.md](WAZUH.md) for how the SIEM itself is put together.

## What the hardware can carry

Incus has the **`qemu` driver alongside `lxc`**, `/dev/kvm` is present, and the
CPUs expose `vmx`/`ept`/`vpid`. Full VMs work, not just containers — that is what
makes a real lab possible here.

| | |
| --- | --- |
| CPU | 2× Xeon E5-2407, 8 cores total |
| Threads per core | 1 — no hyperthreading |
| Clock | 2.2 GHz, Sandy Bridge (2012) |
| AVX2 | absent (only `avx`) |
| RAM | 94 GB |
| Pool | `tank`, 1.81 T, ~1.75 T free |

**Cores are the budget, not memory.** Eight slow cores, and the Wazuh indexer is
a 1 GB-heap JVM that stays busy on its own. Plan on 2–4 concurrent VMs. Memory
will never be the limit.

No AVX2 means some modern guest software will not run. Windows 11 wants TPM 2.0
and Secure Boot — possible with vTPM and OVMF, but painful on this vintage. Use
**Windows Server 2019/2022 and Windows 10**, which install cleanly.

## The gap that matters: no Windows

Analyst work is overwhelmingly Windows — Security event logs, Sysmon,
Kerberoasting, DCSync, lateral movement, LOLBins. A Linux-only lab covers maybe a
third of the job, and not the third that comes up in interviews.

The highest-value single addition is a small AD lab: **Windows Server as a DC, one
Windows 10 client, Sysmon, and the Wazuh agent**. Wazuh's Windows agent is a real
MSI and works properly — unlike the NixOS hosts, which get log forwarding only,
a Windows guest gets full FIM, SCA, syscollector and active response.

## Working pattern: build wet, detonate dry

`labbr0` has `ipv4.nat = false` and no uplink, which is correct for detonation and
means an instance there cannot download an agent, activate Windows, or pull
updates. So:

1. build on `incusbr0` (NAT'd, has a route out) — install the OS, Sysmon, the
   Wazuh agent, enrol it
2. `incus snapshot <name> clean`
3. move the NIC to `labbr0`, or relaunch with `-p lab`, for the attack
4. `incus restore <name> clean` afterwards

Step 2 is what makes the lab reusable rather than something rebuilt every
weekend. On a ZFS pool those snapshots are near-instant and near-free.

## Roadmap

Roughly in order of value.

1. **Windows AD pair** — Server as DC plus a Win10 client on `incusbr0`, Sysmon
   and the Wazuh agent on both. Biggest jump in realism available.
2. **Suricata on `sarten`** — `suricata-8.0.3` is in nixpkgs and Wazuh ships
   `eve.json` decoders, so network detections land beside host detections with no
   custom rule writing. Seeing the same attack from both angles is where the
   learning compounds.
3. **A vulnerable Linux target on `labbr0`** — something to attack with the
   tooling already on `p1`, then go find the traces.
4. **Atomic Red Team** — pre-labelled, MITRE-mapped attacks, so detections can be
   checked rather than guessed at.
5. **Custom rules and decoders** — the media services currently land as generic
   syslog: searchable, no alerts. Writing decoders for one of them is what makes
   the rule syntax stick.
6. **`docker-listener` wodle** — needs `/var/run/docker.sock` bound into the
   manager; gives container lifecycle events.

## Learning the tooling

- `wazuh-logtest` is the best single tool for understanding Wazuh. Paste a raw
  log line and watch it decode, then match, with the phase breakdown:
  ```
  docker exec -it single-node-wazuh.manager-1 /var/ossec/bin/wazuh-logtest
  ```
- `/var/ossec/logs/alerts/alerts.json` is what the dashboard renders. Reading it
  directly is faster than clicking during a rule-writing loop.
- Only events that match a rule are written. Non-matching events are dropped
  unless archives are enabled, which is why a plain test message appears nowhere.

## Known problems

**`hermes-agent` floods the journal.** It crash-loops on a missing
`hermes_state_holders` module, and `hermes-agent` plus `hermes-backend` are the
top two log producers on `sarten` by a wide margin. On first start the forwarder
lost 1,179,870 messages to rate-limiting. It is not just wasted CPU — it drowns
the signal the SIEM exists to find. Fix or disable it before tuning anything.

**Syslog is UDP and lossy.** Only 514/udp is published by the compose file, so
`p1` off the tailnet drops its logs silently rather than queueing. Moving to TCP
is one line in the compose ports, one in the manager's `<remote>` block, and one
in the `wazuh-syslog` aspect.

**Indexer retention is unbounded.** No index lifecycle policy, so it grows on
`tank` forever. Worth setting before there are months of data.

**`allowed-ips` is not the control.** Docker's userland proxy rewrites the source
address, so every event reaches the manager as `172.18.0.1` regardless of sender.
The NixOS firewall is what actually restricts this — 514/udp is not in
`allowedUDPPorts` and `tailscale0` is a trusted interface. Host attribution still
works, because Wazuh reads the hostname from the message rather than the packet.
