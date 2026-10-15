# p1: the system as built (2026-10)

What `install.md` → `setup.md` → `scripts/` actually produced on p1 (ThinkPad P1 Gen 7), kept for
a rebuild. The guides say how; this folder is the result, to diff against or copy from.

| Path | What |
|---|---|
| `etc/portage/` | `make.conf` (final: `~amd64`, LTO, `lto pgo`), its `.bak` stages (stable → pretune → prelto), `package.*`, `env/`, `repos.conf`, `savedconfig/` (kernel, linux-firmware), `make.profile.txt` (the profile symlink) |
| `etc/kernel/` | `cmdline`, `uki.conf` (with the creds `Phases=`), `install.d/`; `certs-list.txt` only names the keys |
| `var-lib-portage/` | `world` (+ `world_sets`), and `installed.txt`: every installed package and version |
| `notes/` | `bootinfo.txt` (`bootctl` output), `kernel-config.log` (first `emerge --config` of 7.2.10), `after-boot.txt` (checks after the 7.2.10 reboot, NvPCR errors) |
| `logs-2026-10.tar.xz` | `~/.local/state/p1-setup/logs`: every stage1/stage2/games run, plus dry runs and early build logs |

Not here, on purpose (the repo is public): the Secure Boot, module-signing and PCR private keys
(`/etc/kernel/certs`, `/var/lib/sbctl`), `/etc/portage/gnupg`. The machine-id is masked in `notes/`.
Back those up somewhere private.

Refresh after big changes:

```bash
D=~/git/dots/gentoo/p1
cd /etc/portage && cp -a make.conf make.conf.*.bak binrepos.conf env package.* profile repos.conf savedconfig $D/etc/portage/
cp -a /etc/kernel/cmdline /etc/kernel/uki.conf /etc/kernel/install.d $D/etc/kernel/
cp /var/lib/portage/world* $D/var-lib-portage/ && qlist -IRv | sort > $D/var-lib-portage/installed.txt
```
