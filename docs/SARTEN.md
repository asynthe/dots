# `sarten`

HP ProLiant ML350e Gen8 v2, headless, on the LAN and the tailnet. Two Xeon
E5-2407, 94 GB of RAM, two 500 GB SATA disks on the onboard AHCI controller —
despite the ProLiant badge there is no Smart Array in this one, so `hpsa` and
`smartpqi` are not needed and are not loaded.

**It was adopted, not installed.** The box was already running a stock NixOS
26.05 from the graphical installer when it joined this flake, so there is no
disko step and no `nixos-anywhere` run: `sda` keeps the layout the installer
gave it, and the flake was pointed at the machine as it stood. That is the one
real difference from `p1`, and it has a consequence worth stating plainly —
**this host's partitioning is not declarative.** Rebuilding it from bare metal
means redoing the manual steps in [Rebuilding from scratch](#rebuilding-from-scratch),
not just running one command.

The host is three files, and only `default.nix` is meant to be edited often:

| file | what it holds |
| --- | --- |
| `nix/hosts/sarten/default.nix` | the aspect list, the per-host `sys.*` values, the static network |
| `nix/hosts/sarten/filesystems.nix` | the `sarten-filesystems` aspect — `fileSystems`, swap, GRUB's target disk |
| `nix/hosts/sarten/hardware.nix` | the `sarten-hardware` aspect — initrd modules, microcode |

## Disk layout

Legacy BIOS, two disks, no encryption. `sda` is as the installer left it; `sdb`
was wiped by hand and holds nothing but the media library.

| device | label | size | contents |
| --- | --- | --- | --- |
| `sda1` | `root` | 457G | ext4, mounted at `/` — `/boot` is a directory inside it, not a partition |
| `sda2` | `swap` | 8.8G | swap partition |
| `sdb1` | `media` | 466G | ext4, mounted at `/srv/media` — Jellyfin's library |

Everything is addressed by label, and GRUB's target disk by `by-id`, because
`/dev/sd*` is probe order: the two drives are the same model and can swap.

`/srv/media` mounts `nofail`. A media disk that fails to appear must not hold up
boot on a machine with no console attached.

Three deliberate differences from `p1`:

**No LUKS.** The box is headless. An encrypted root turns every unattended
reboot — a power cut, a kernel update — into a machine sitting at a passphrase
prompt nobody is in the room to answer. The alternative, an SSH server in the
initrd, is a second boot-time network stack to keep working. Neither is worth it
for a media and agent host on a home LAN.

**No impermanence.** The rollback is only as good as what `/persist` captures,
and debugging a missing persist entry on a remote box means losing the state
that would have told you what went wrong. Every aspect still declares its
`environment.persistence` entries; they are `mkIf`-guarded off, so the host wipes
`environment.persistence` with `mkForce` to stop the module warning about uid
stability it cannot verify.

**GRUB, not systemd-boot.** The `boot` aspect is systemd-boot, which is UEFI
only. `sarten` imports `boot-bios` instead — never both. `boot-bios` turns GRUB
on but names no target disk; with no disko module here, `filesystems.nix` is
what sets `boot.loader.grub.devices`. An empty list installs no bootloader at
all, so that line is load-bearing.

## Networking

Static, on `eno1`, at `192.168.1.135/24` via `192.168.1.1`. The box has six
ethernet ports and one cable.

The `network` aspect is written for the laptop: it disables NetworkManager and
drives `iwd` instead. This machine has no wireless hardware whatsoever, so
importing that aspect unchanged would leave it with nothing able to configure an
address — a guaranteed lockout on the first switch. `default.nix` therefore
forces `iwd` off and declares the address by hand. Scripted networking brings it
up through `network-addresses-eno1.service`; no DHCP client is involved.

If the address ever has to change, change it *and* reboot with a console
available. There is no second way in over the LAN.

## Access

`sys.ssh.authorizedKeys` is non-empty, which is what turns password auth off —
the list is the only way in, and `meow@p1` is first in it because `p1` is the
machine that deploys this one. Root login is off.

The installer's original `sarten` *account* -- same word as the host name, unrelated thing -- did **not** survive the first switch,
and `users.mutableUsers = true` is not the escape hatch it looks like: it allows
users created by hand with `useradd` to persist, but `sarten` was declared in
the old `/etc/nixos/configuration.nix`, so NixOS considered it a managed user
and `update-users-groups.pl` removed it the moment it stopped being declared.
Only `/home/sarten` is left behind. Anything that has to outlive a switch has to
be in this flake.

The fallback is therefore whatever else is in the key list. That is one key,
`s24`, so the margin is thin: if both it and `p1`'s key go, the only way back in
is the physical console.

A second account, `user`, is declared in `default.nix` as a key-only login: no
password, not in `wheel`, so it can ssh in and cannot `sudo` or `su`. The same
keys reach it through `sys.ssh.extraUsers` — the `ssh` aspect always includes
`sys.user` and appends that list, so nothing set there can lock `meow` out. It is
not named after the host, which is what made the installer's `sarten` account
confusing, and it is not a system user either: `jellyfin` and `hermes` are those,
with no shell and no home.

One nixpkgs trap worth knowing, which this account happens to sidestep. Under
`users.mutableUsers = true` an *existing* `/etc/shadow` entry is carried over
verbatim — `update-users-groups.pl` only writes `!` for a password when
`mutableUsers` is false, or when the entry is new. Declaring no password does not
clear one, and neither does `hashedPassword = "!"`; the script carries a standing
FIXME about exactly that. `user` gets a fresh entry, so it is locked properly. An
account *adopted* from a previous install would keep whatever password it had and
needs `sudo passwd -l <name>` once.

`root` is the mirror image of that. `sys.sops.rootPassword = true` points it at
the same hash as `meow`, so `su` works and nothing new is granted — `meow` is in
`wheel` and already sudos to root. It reuses that secret rather than a
`users/root` key because a key missing from `secrets.yaml` fails activation
outright. But root's shadow entry predates this flake, so the same trap applies:
the declaration is inert here until `sudo passwd root` is run once. A host
installed fresh gets it without that step.

## The secret that has to arrive first

`sops` decrypts `secrets/secrets.yaml` with a private age identity, and the
`user-password` secret is `neededForUsers` — **activation fails outright if the
identity is missing**, which fails the whole switch. `p1` keeps the identity in
`/persist`; `sarten` has no `/persist`, so `sys.sops.ageKeyFile` points at
`/var/lib/sops/age-keys.txt` instead.

Both hosts use the same age identity, so nothing needs re-encrypting. It is
already staged on the box. To redo it:

```bash
ssh root@192.168.1.135 'install -d -m 0755 /var/lib/sops'
scp ~/git/auth/age/keys.txt root@192.168.1.135:/var/lib/sops/age-keys.txt
ssh root@192.168.1.135 'chmod 0600 /var/lib/sops/age-keys.txt'
```

That is a plaintext private key sitting on the server; it is the price of
`neededForUsers`, and it is why the file is root-owned and `0600`.

## Rebuilding

From a checkout on `p1` — builds locally, pushes the closure, the ProLiant
compiles nothing:

```bash
nixos-rebuild switch --flake .#sarten --target-host meow@192.168.1.135 \
    --sudo --ask-sudo-password
```

`meow`'s password comes from sops and `wheel` is not passwordless, so the sudo
prompt is unavoidable unless you decide otherwise.

Or on the box itself:

```bash
ssh meow@192.168.1.135
nh os switch -H sarten /home/meow/dots
```

Once it is on the tailnet, `sarten` works in place of the IP.

## After the first switch

Join the tailnet by hand — it is the one step that needs an interactive login:

```bash
ssh meow@192.168.1.135
sudo tailscale up
```

Jellyfin serves `/srv/media` on `:8096` with `sys.jellyfin.openFirewall = false`,
so it is reachable over tailscale and not from the LAN — see [MEDIA.md](MEDIA.md).
Hermes binds its dashboard to the name `sarten` and waits for it to resolve,
which is why `sys.hermes.waitForHost` is set — see [HERMES.md](HERMES.md).
Neither is reachable until `tailscale up` has been run.

## Rebuilding from scratch

The manual steps, in order, if the disks are ever replaced. `sda` is assumed to
already carry a NixOS install with SSH reachable.

```bash
# 1. the media disk -- DESTROYS /dev/sdb
wipefs -a /dev/sdb
printf 'label: gpt\n,,L\n' | sfdisk /dev/sdb
mkfs.ext4 -m 0 -L media /dev/sdb1

# 2. labels the flake expects on the root disk
e2label /dev/sda1 root
swaplabel -L swap /dev/sda2

# 3. the age identity (see above), then switch
```

`mkfs.ext4 -m 0` skips the usual 5% reserve. That default exists to keep root
able to write on a full filesystem; on a disk that holds only a media library it
is 23 GB thrown away.
