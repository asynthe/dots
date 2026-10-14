# Gentoo on p1: install

Run by hand from the LiveGUI USB, step by step. The Gentoo Handbook (amd64) covers anything not
here, and this file wins on conflicts.

This file **only installs**. It ends with the laptop booting to a tty: disks formatted and
encrypted, base system running, Secure Boot on, TPM + PIN unlock, Wi-Fi. Everything you add on
top of that (Hyprland, apps, your files, dots) is `setup.md`, and every package is in
`packages.md`. All three live in `~/git/dots/gentoo/`.

Revised 2026-10-14, for a reinstall over Windows 11 on Intel RST RAID0 (first install
2026-10-01, over NixOS).

## Machine

- Core Ultra 7 155H (22 threads, avx2, no avx512), 30G RAM, TPM 2.0, UEFI
- 2× Crucial P3 4TB CT4000P3PSSD8: `nvme0n1` serial …8BA3FDF, `nvme1n1` serial …8BA3FD2
- Intel Arc (primary) + RTX 2000 Ada (offload), Wi-Fi BE200
- Goodix fingerprint 27c6:6594 (libfprint goodixmoc: supported)

## Rules

1. Only `nvme0n1` + `nvme1n1` (CT4000P3PSSD8) get touched, never an external drive or the USB.
   Run `lsblk` before every destructive command, because device names can change.
2. Passphrases, PINs and passwords are typed at prompts, never on a command line.
3. Long commands: paste them on **one line**, or end every line with ` \`. A bare line break
   runs the first half alone (step 18 once enrolled a TPM token with no PIN that way).
4. 3 wrong `sudo`/`su` passwords and `pam_faillock` locks the account for 10 minutes. After
   that even the right password gets "Sorry, try again". Wait it out, then
   `sudo faillock --user meow --reset`.

## Layout

| | |
|---|---|
| `nvme0n1p1` | 2G ESP, `/efi` |
| `nvme1n1p1` | 2G spare (unformatted) |
| `nvme0n1p2` + `nvme1n1p2` | md0 raid0 → LUKS2 aes-xts-512 → btrfs `@ @home @snapshots @log @distfiles @binpkgs` |
| Kernel | `sys-kernel/gentoo-kernel`, built locally with its own module-signing key, so nvidia works under Secure Boot |
| Boot | systemd-boot + signed UKI. Unlock: TPM2 (PCR7 + signed PCR11 policy) + PIN, with passphrase and recovery key as fallback |

**sudo:** steps 0-8 run as the live user `gentoo`, with `sudo` on each command that needs root.
Steps 9-16 run **inside the chroot**, where you're already root, so no `sudo` there (it isn't
even installed yet). From step 16 on, `sudo` again.

## Before: from Windows

Windows runs on an **Intel RST RAID0 volume** ("Intel Raid 0 Volume", `raid-win`): the firmware
does the striping, through Intel VMD. Linux would see that as IMSM metadata behind the VMD
controller, not as the two plain NVMe drives this guide uses (md0 is mdadm's own raid, like on
NixOS). So the firmware RAID goes away first.

1. **Back up** everything you want from `C:`. The array goes away in step 1, and step 2 erases
   both drives.
2. **USB:** write `livegui-amd64-<date>.iso` (in `Downloads`, sha256 + gpg checked) with Rufus
   in **DD mode**: when it asks ISO or DD, pick DD, as Gentoo's docs say.
3. **Firmware (F1 at the Lenovo logo):**
   - Config → Storage: switch the controller from RAID / Intel RST (VMD) to plain **NVMe**
     (AHCI on some BIOS versions). The drives must show up as two separate disks.
   - Security → Secure Boot: **off**. The live USB isn't signed with keys this machine trusts,
     and step 17 resets the keys anyway.
   - Security → Security Chip: **Clear Security Chip** (the TPM). Windows/BitLocker owned it,
     and nothing on it survives the wipe. Step 18 enrolls a fresh one.
4. Boot the USB (F12 → USB).

## 0. Pre-flight

The date must be correct (TLS + gpg). Fix it with `sudo date -s "YYYY-MM-DD HH:MM"`.
Wi-Fi in the LiveGUI: the network applet in the panel, or `nmtui`.

```bash
date
ping -c2 gentoo.org
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,LABEL
```

`lsblk` must show `nvme0n1` and `nvme1n1` as two 3.6T disks. If it shows one ~7.3T `md126`, or
`isw_raid_member` in FSTYPE, RST/VMD is still on in the firmware: go back and turn it off.

The guides, on the live system (read-only copy; step 16 puts them on the new disk):

```bash
git clone --depth 1 https://gitlab.com/asynthe/dots.git ~/dots && less ~/dots/gentoo/install.md
```

If the live system has no git: `curl -fLO https://gitlab.com/asynthe/dots/-/raw/main/gentoo/install.md`
(same for `setup.md`, `packages.md`).

## 1. Wipe the old Intel RST array

Even with RST off, the RAID metadata (IMSM) is still at the end of each drive, and the live USB
may auto-assemble it as `md127` (container) + `md126` (the Windows volume). Stop both, then erase
the metadata.

```bash
cat /proc/mdstat
sudo mdadm --stop --scan
sudo mdadm --examine /dev/nvme0n1 /dev/nvme1n1 | grep -E 'Magic|Container'   # "Intel Raw RAID"
sudo mdadm --zero-superblock /dev/nvme0n1 /dev/nvme1n1
sudo wipefs -a /dev/nvme0n1 /dev/nvme1n1
sudo mdadm --examine /dev/nvme0n1 /dev/nvme1n1   # "No md superblock detected" on both
```

## 2. 4K LBA + secure erase

Format index 1 = 4096 bytes, on both drives. `--ses=1` makes it a User Data Erase: the drive
really erases every block (Windows' data included) instead of only remapping them. If a drive
rejects `--ses=1` ("Invalid Field"), run the same line without it.

```bash
sudo nvme id-ns -H /dev/nvme0n1 | grep 'LBA Format'      # expect "LBA Format 1 : ... 4096"
sudo nvme id-ns -H /dev/nvme1n1 | grep 'LBA Format'
sudo nvme format /dev/nvme0n1 --lbaf=1 --ses=1
sudo nvme format /dev/nvme1n1 --lbaf=1 --ses=1
lsblk -o NAME,SIZE,LOG-SEC,PHY-SEC /dev/nvme0n1 /dev/nvme1n1   # LOG-SEC must be 4096
```

## 3. Partitions

```bash
sudo sgdisk --zap-all /dev/nvme0n1
sudo sgdisk -n1:0:+2G -t1:ef00 -c1:ESP  -n2:0:0 -t2:fd00 -c2:raid0a /dev/nvme0n1
sudo sgdisk --zap-all /dev/nvme1n1
sudo sgdisk -n1:0:+2G -t1:ef00 -c1:ESP2 -n2:0:0 -t2:fd00 -c2:raid0b /dev/nvme1n1
sudo partprobe; lsblk -o NAME,SIZE,PARTLABEL /dev/nvme0n1 /dev/nvme1n1
sudo mkfs.vfat -F32 -n EFI /dev/nvme0n1p1
```

## 4. RAID0

`--homehost=any`, because otherwise the array is named "livecd:p1" and comes up as a foreign
`md127` later.

```bash
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 --chunk=512 --metadata=1.2 \
      --homehost=any --name=p1 /dev/nvme0n1p2 /dev/nvme1n1p2
cat /proc/mdstat
```

## 5. LUKS2

AES-256-XTS (512-bit key), 4K sectors, argon2id at 4 GiB (the max). Unlocking takes about 3 s.

```bash
sudo cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 \
      --sector-size 4096 --hash sha512 --pbkdf argon2id \
      --pbkdf-memory 4194304 --pbkdf-parallel 4 --iter-time 3000 /dev/md0
```

Discards and no-workqueue get stored in the LUKS header (`--persistent`):

```bash
sudo cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue \
      --persistent /dev/md0 cryptroot
sudo cryptsetup luksDump /dev/md0 | grep -E 'Flags|sector|Cipher'
```

## 6. Btrfs

```bash
sudo mkfs.btrfs -L gentoo /dev/mapper/cryptroot
sudo mkdir -p /mnt/gentoo
sudo mount /dev/mapper/cryptroot /mnt/gentoo
for s in @ @home @snapshots @log @distfiles @binpkgs; do sudo btrfs subvolume create /mnt/gentoo/$s; done
sudo umount /mnt/gentoo
O=noatime,compress=zstd:1,ssd,discard=async,space_cache=v2
sudo mount -o $O,subvol=@ /dev/mapper/cryptroot /mnt/gentoo
sudo mkdir -p /mnt/gentoo/{home,.snapshots,var/log,var/cache/distfiles,var/cache/binpkgs,efi}
sudo mount -o $O,subvol=@home      /dev/mapper/cryptroot /mnt/gentoo/home
sudo mount -o $O,subvol=@snapshots /dev/mapper/cryptroot /mnt/gentoo/.snapshots
sudo mount -o $O,subvol=@log       /dev/mapper/cryptroot /mnt/gentoo/var/log
sudo mount -o $O,subvol=@distfiles /dev/mapper/cryptroot /mnt/gentoo/var/cache/distfiles
sudo mount -o $O,subvol=@binpkgs   /dev/mapper/cryptroot /mnt/gentoo/var/cache/binpkgs
sudo mount -o umask=0077 /dev/nvme0n1p1 /mnt/gentoo/efi
findmnt -R /mnt/gentoo
```

## 7. Stage3 (verified)

`gpg --verify` must say "Good signature from Gentoo ebuild repository signing key".

```bash
cd /mnt/gentoo
B=https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd
F=$(curl -s $B/latest-stage3-amd64-desktop-systemd.txt | grep -o 'stage3-[^ ]*\.tar\.xz' | head -1); echo $F
sudo wget $B/$F $B/$F.asc
gpg --import /usr/share/openpgp-keys/gentoo-release.asc
gpg --verify $F.asc $F
sudo tar xpf $F --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
sudo rm $F $F.asc
ls -ld /mnt/gentoo/var/cache/{distfiles,binpkgs}   # tar sets owner/perms from the stage3 (root:portage)
```

## 8. Chroot

```bash
sudo cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
sudo mount --types proc /proc /mnt/gentoo/proc
sudo mount --rbind /sys /mnt/gentoo/sys && sudo mount --make-rslave /mnt/gentoo/sys
sudo mount --rbind /dev /mnt/gentoo/dev && sudo mount --make-rslave /mnt/gentoo/dev
sudo mount --bind /run /mnt/gentoo/run && sudo mount --make-slave /mnt/gentoo/run
sudo chroot /mnt/gentoo /bin/bash
```

> **You're now root inside the new system, with no `sudo` until step 16.** Every file edit in
> steps 9-15 must happen here, where the prompt says `(chroot) livecd`. Editing `/etc/...`
> from a `gentoo@livecd` terminal changes the live USB, not the new system.

```bash
source /etc/profile; export PS1="(chroot) $PS1"
ls /sys/firmware/efi/efivars | head -2      # must list files (bootctl needs it)
```

## 9. Portage

```bash
emerge-webrsync
eselect profile list | grep 'desktop/systemd'
eselect profile set default/linux/amd64/23.0/desktop/systemd
```

`/etc/portage/make.conf`, replace the whole file:

```bash
# Not -march=native: on this hybrid CPU it reports different cache sizes per core (P/E/LP-E),
# and gcc's PGO bootstrap aborts on that (bug #915389). These flags = exactly what native
# enables, minus the cache params (gcc -Q --help=target, checked against native, 2026-10-01).
COMMON_FLAGS="-march=meteorlake -mabm -mshstk -mno-kl -mno-pconfig -mno-sgx -mno-widekl -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="-C target-cpu=native"
# ~2 GB RAM per job: 30G -> 15. jobs=2 keeps worst case ~30 compilers.
MAKEOPTS="-j15 -l22"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=22 --with-bdeps=y"
FEATURES="getbinpkg binpkg-request-signature parallel-fetch"
ACCEPT_LICENSE="*"
# Stable for the install (binhost = fast). setup.md §17 switches to ~amd64 at the very end.
VIDEO_CARDS="intel nvidia"
INPUT_DEVICES="libinput"
USE="wayland pipewire vaapi vulkan dist-kernel systemd bluetooth secureboot modules-sign -gnome -kde"
GRUB_PLATFORMS=""
L10N="en es ja"
MICROCODE_SIGNATURES="-S"
# Secure Boot: sbctl db key signs systemd-boot (and other .efi). Created in step 11.
SECUREBOOT_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
SECUREBOOT_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
# Own module-signing key: kernel trusts it, nvidia modules get signed with it. Created in step 11.
MODULES_SIGN_KEY="/etc/kernel/certs/signing_key.pem"
MODULES_SIGN_CERT="/etc/kernel/certs/signing_key.pem"
```

Binhost x86-64-v3, in `/etc/portage/binrepos.conf/gentoobinhost.conf`:

```ini
[gentoobinhost]
priority = 1
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-v3/
```

```bash
getuto
```

CPU flags: tell every package which instructions this CPU has (AVX, AVX2, AES, …). Without
them packages build for the lowest common denominator, and some (claude-code) refuse to build.
This must happen before any other emerge.

They go in `make.conf` as `CPU_FLAGS_X86`, and **only** there: no `package.use/00cpu-flags`
file. The flags add up across files, so a second list would keep any stale flag switched on.
Write them from the tool's output, never from a list copied from somewhere else:

```bash
emerge --oneshot app-portage/cpuid2cpuflags
cpuid2cpuflags | sed 's/^.*CPU_FLAGS_X86: \(.*\)/CPU_FLAGS_X86="\1"/' >> /etc/portage/make.conf
tail -1 /etc/portage/make.conf       # CPU_FLAGS_X86="aes avx avx2 avx_vnni … vpclmulqdq" (21 flags)
ls /etc/portage/package.use/         # no 00cpu-flags
portageq envvar CPU_FLAGS_X86        # same list as the make.conf line
```

Expected on p1 (cpuid2cpuflags 17 and 18, run in WSL on this laptop, 2026-10-14):
`aes avx avx2 avx_vnni bmi1 bmi2 f16c fma3 mmx mmxext pclmul popcnt rdrand sha sse sse2 sse3
sse4_1 sse4_2 ssse3 vpclmulqdq`. If the chroot shows a different list, trust the chroot, not this.
Version 18 starts its output with `*/* `, which the `sed` above strips too.

Binhost packages are built with generic CPU flags, so a package whose `CPU_FLAGS_X86` differ
from these (ffmpeg, x264, some crypto libs) builds from source instead. That's expected.

`/etc/portage/package.use/p1`. fwupd's `uefi` builds the `fwupdx64.efi` helper (this firmware can't take capsules from disk),
and `USE=secureboot` signs it.

```text
sys-kernel/installkernel dracut systemd systemd-boot uki ukify
sys-apps/systemd boot ukify cryptsetup tpm
sys-fs/cryptsetup argon2
media-video/pipewire sound-server
x11-drivers/nvidia-drivers wayland powerd
sys-apps/fwupd uefi
```

## 10. Base config

Ask which timezone (p1's is `America/Santiago`).

```bash
echo p1 > /etc/hostname
ln -sf ../usr/share/zoneinfo/<Region/City> /etc/localtime
```

`/etc/locale.gen`:

```text
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
```

```bash
locale-gen
eselect locale list; eselect locale set <en_US.utf8 number>
env-update && source /etc/profile && export PS1="(chroot) $PS1"
```

**Keymap:** the LUKS passphrase and PIN are typed with the **initramfs** keymap, so set it before
the kernel. Change `us` if your layout isn't US.

```bash
echo 'KEYMAP=us' > /etc/vconsole.conf
systemd-machine-id-setup
```

## 11. Keys (Secure Boot + module signing)

`sbctl create-keys` only makes the keys. Enrolling them happens after first boot (step 17).

```bash
emerge -av app-crypt/sbctl app-crypt/sbsigntools
sbctl create-keys
ls /var/lib/sbctl/keys/db/       # must show db.key db.pem (fix make.conf if the path differs)
```

```bash
mkdir -p /etc/kernel/certs && cd /etc/kernel/certs
cat > x509.genkey <<'EOF'
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts
[ req_distinguished_name ]
CN = p1 kernel module signing key
[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF
openssl req -new -nodes -utf8 -sha512 -days 36500 -batch -x509 -config x509.genkey \
  -outform PEM -out signing_key.pem -keyout signing_key.pem
chmod 600 signing_key.pem; cd /
```

PCR signing key. ukify uses it to sign, inside every UKI, the PCR11 value that UKI will produce.
Step 18 binds the disk to this key, so the TPM releases the disk key only under a UKI you built
and signed, and only **while the initrd runs**: once boot leaves the initrd, PCR11 moves on and
the TPM refuses. That blocks the attack where someone swaps in their own root filesystem and asks
the TPM for the key from there. Kernel updates need no re-enroll, because each new UKI carries its
own signature. (systemd 262 also needs this initrd-phase signature to set up NvPCRs; without it,
three TPM units fail every boot, systemd issue #43848.)

It lives here, **not** at `/etc/systemd/tpm2-pcr-public-key.pem`, so `systemd-cryptenroll` only
binds to it when step 18 passes it explicitly.

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /etc/kernel/certs/pcr-private-key.pem
openssl pkey -in /etc/kernel/certs/pcr-private-key.pem -pubout -out /etc/kernel/certs/pcr-public-key.pem
chmod 600 /etc/kernel/certs/pcr-private-key.pem
```

`/etc/kernel/uki.conf`. ukify Secure Boot signs every UKI it builds, adds the PCR11 signature
for the initrd phase only (`Phases=enter-initrd`), and takes its os-release from the hook below:

```ini
[UKI]
SecureBootSigningTool=sbsign
SecureBootPrivateKey=/var/lib/sbctl/keys/db/db.key
SecureBootCertificate=/var/lib/sbctl/keys/db/db.pem
SignInitrdPCRs=yes
OSRelease=@/run/kernel/os-release-uki

[PCRSignature:p1]
PCRPrivateKey=/etc/kernel/certs/pcr-private-key.pem
PCRPublicKey=/etc/kernel/certs/pcr-public-key.pem
Phases=enter-initrd
```

Boot menu titles: systemd-boot names a UKI after its os-release, which on Gentoo has the
baselayout version (2.18) for every kernel, so all entries look alike and get their filename
appended. This hook gives each UKI its own kernel version, so the menu reads
`Gentoo Linux (7.2.8)`:

```bash
mkdir -p /etc/kernel/install.d
cat > /etc/kernel/install.d/59-osrel.install <<'EOF'
#!/bin/sh
# Boot menu title per kernel, "Gentoo Linux (7.2.8)": ukify reads this via OSRelease= in uki.conf.
[ "$1" = add ] || exit 0
v=${2%%-*}
mkdir -p /run/kernel
{ grep -vE '^(VERSION_ID|IMAGE_VERSION)=' /etc/os-release; printf "VERSION_ID='%s'\nIMAGE_VERSION='%s'\n" "$v" "$v"; } > /run/kernel/os-release-uki
EOF
chmod +x /etc/kernel/install.d/59-osrel.install
```

## 12. Boot config (before the kernel is built)

`/etc/dracut.conf.d/p1.conf`:

```bash
add_dracutmodules+=" mdraid crypt btrfs systemd tpm2-tss "
hostonly="yes"
compress="zstd"
```

The UUIDs. The stage3 has no mdadm or cryptsetup yet (they come in step 13), so run these
three in a **second terminal on the live system**, not chrooted:

```bash
sudo mdadm --detail /dev/md0 | grep UUID                    # ARRAY-UUID (with colons)
sudo cryptsetup luksUUID /dev/md0                           # LUKS-UUID
sudo mdadm --detail --scan | sudo tee -a /mnt/gentoo/etc/mdadm.conf
```

Back in the chroot:

```bash
blkid /dev/mapper/cryptroot /dev/nvme0n1p1      # BTRFS-UUID, ESP-UUID
```

`/etc/kernel/cmdline`, one line:

```text
rd.md.uuid=<ARRAY-UUID> rd.luks.name=<LUKS-UUID>=cryptroot rd.luks.options=tpm2-device=auto root=/dev/mapper/cryptroot rootflags=subvol=@ rw nvidia-drm.modeset=1 nvidia-drm.fbdev=1 init_on_free=1 quiet
```

The `name=` field may be missing from the ARRAY line, and that's fine. When mdadm gets emerged in
step 13, **keep** this file in etc-update/dispatch-conf, because it has the ARRAY line.

```bash
tail -1 /etc/mdadm.conf          # ARRAY /dev/md0 metadata=1.2 UUID=...
```

`/etc/fstab`:

```text
UUID=<BTRFS-UUID>  /                    btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@           0 0
UUID=<BTRFS-UUID>  /home                btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@home       0 0
UUID=<BTRFS-UUID>  /.snapshots          btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@snapshots  0 0
UUID=<BTRFS-UUID>  /var/log             btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@log        0 0
UUID=<BTRFS-UUID>  /var/cache/distfiles btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@distfiles  0 0
UUID=<BTRFS-UUID>  /var/cache/binpkgs   btrfs  noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@binpkgs    0 0
UUID=<ESP-UUID>    /efi                 vfat   umask=0077                                                                  0 2
```

```bash
findmnt --verify --fstab
```

`/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

## 13. World + kernel

`bootctl install` installs the signed systemd-boot to `/efi`. The second emerge makes sure the
secureboot/boot build of systemd is in place.

```bash
emerge -avuDN @world
emerge -av sys-apps/systemd
bootctl install
```

`/efi/loader/loader.conf`:

```text
timeout 3
editor no
```

**First** the tools dracut needs inside the initramfs, **then** the kernel. Otherwise dracut
fails with "Module 'btrfs' / 'tpm2-tss' cannot be installed". (dracut's `tpm2-tss` module needs
the `tpm2` binary from `app-crypt/tpm2-tools`.) The `rm` keeps **your** `mdadm.conf`, the one
with the ARRAY line, and drops the default.

```bash
emerge -av sys-fs/btrfs-progs sys-fs/mdadm sys-fs/cryptsetup app-crypt/tpm2-tss app-crypt/tpm2-tools
rm /etc/._cfg0000_mdadm.conf
emerge -av \
  sys-kernel/gentoo-kernel \
  sys-firmware/sof-firmware \
  sys-fs/dosfstools sys-apps/nvme-cli sys-apps/zram-generator \
  net-wireless/iwd net-wireless/bluez app-shells/zsh app-admin/sudo \
  dev-vcs/git app-editors/neovim net-misc/rsync app-eselect/eselect-repository \
  sys-apps/fwupd sys-power/thermald sys-power/power-profiles-daemon sys-boot/efibootmgr
```

- gentoo-kernel compiles locally (~30-60 min). That's the price of signed nvidia modules.
- If it ends with `dracut[E]: Module 'X' cannot be installed`, the kernel itself is fine.
  Install the missing tool, then rebuild only the initramfs + UKI (no recompile):
  `emerge --config sys-kernel/gentoo-kernel`
- If emerge stops partway through the list, the remaining packages were **not** installed.
  Rerun the same emerge.

Firmware and microcode go in **after** the kernel. Their postinst rebuilds the UKI, and with no
kernel installed yet that fails ("Kernel install failed") and stops the emerge. On 2026-10-01
that left both uninstalled, and Wi-Fi only worked from a firmware copy inside the UKI.

```bash
emerge -av sys-kernel/linux-firmware sys-firmware/intel-microcode
ls -d /var/db/pkg/sys-kernel/linux-firmware-* /var/db/pkg/sys-firmware/intel-microcode-*   # both exist
```

## 14. Verify the boot chain + EFI entries (don't skip this)

There should be one UKI, named `<machine-id>-<kver>-gentoo-dist.efi`. All three `sbverify` lines
must say "Signature verification OK". The command line should match `/etc/kernel/cmdline`, plus
`systemd.machine_id=…`, which is normal.

```bash
U=$(ls /efi/EFI/Linux/*.efi); echo $U
sbverify --cert /var/lib/sbctl/keys/db/db.pem $U
sbverify --cert /var/lib/sbctl/keys/db/db.pem /efi/EFI/systemd/systemd-bootx64.efi
sbverify --cert /var/lib/sbctl/keys/db/db.pem /efi/EFI/BOOT/BOOTX64.EFI
lsinitrd $U | sed -n '/^Command line:/,/^====/p'
lsinitrd $U | grep -E 'GenuineIntel.bin|bin/btrfs$|bin/mdadm$|bin/systemd-cryptsetup$|token-systemd-tpm2|libtss2-esys'
```

The last line must show all 6 (some appear twice, as symlinks): `GenuineIntel.bin` (microcode),
`btrfs`, `mdadm`, `systemd-cryptsetup`, `libcryptsetup-token-systemd-tpm2.so`, `libtss2-esys`.
If one is missing, install its package, then run `emerge --config sys-kernel/gentoo-kernel`.

`vconsole.conf` should have the layout you type the passphrase with. Secure Boot shows
"disabled" here, which is OK for now.

```bash
lsinitrd -f etc/mdadm.conf $U        # ARRAY /dev/md0 … UUID=<ARRAY-UUID>
lsinitrd -f etc/vconsole.conf $U     # KEYMAP=…
objdump -h $U | grep -E 'pcrsig|pcrpkey'   # both sections: the signed PCR11 policy + its key
bootctl list --no-pager | grep title   # Gentoo Linux (<kernel version>)
bootctl status                       # loader + ESP found
```

EFI boot entries (this works in the chroot because `/sys` is rbind-mounted):

```bash
efibootmgr
```

- Delete stale entries whose disk no longer exists (here: "Windows Boot Manager", and any
  old Linux Boot Manager from the first install) with `efibootmgr -b XXXX -B`.
- Keep the new "Linux Boot Manager" (on the ESP PARTUUID from `blkid`) and all Lenovo
  FvFile/VenMsg entries.
- "Fallback Linux Boot Manager" points at `systemd-boot-fallbackx64.efi`, which may not exist.
  That's harmless, because `EFI/BOOT/BOOTX64.EFI` is the real fallback. Optional:
  `efibootmgr -b <its number> -B`.

BootOrder should start with the new Linux Boot Manager:

```bash
efibootmgr | head -8
```

## 15. Services + users

```bash
systemctl preset-all --preset-mode=enable-only
systemctl enable iwd systemd-resolved systemd-timesyncd fstrim.timer bluetooth thermald power-profiles-daemon
```

iwd runs on its own, with no NetworkManager, like NixOS did. The quickshell bar reads iwd over
D-Bus. `/etc/iwd/main.conf`:

```ini
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
[Settings]
AutoConnect=true
```

`/etc/systemd/resolved.conf.d/fallback.conf`:

```ini
[Resolve]
FallbackDNS=1.1.1.1 1.0.0.1
```

meow is UID 1000 in group `users` (100), the same as on NixOS. sudo asks for meow's password
(setup.md §6 adds the fingerprint as an alternative). In `visudo`, uncomment
`%wheel ALL=(ALL:ALL) ALL`, and nothing else.

```bash
useradd -m -u 1000 -g users -G wheel,video,audio,input,render -s /bin/zsh meow
passwd meow
passwd
EDITOR=nvim visudo
```

```bash
visudo -c                          # parsed OK
```

Do this **last** in the chroot. It breaks DNS there, because the stub only exists once systemd runs.

```bash
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

## 16. Leave + reboot

```bash
exit                               # back to the live user; sudo again from here
```

Take the guides along (this folder: `install.md`, `setup.md`, `packages.md`). After the
reboot they're the only copy on the laptop until `setup.md` §0 clones dots.

```bash
sudo cp -r <this folder> /mnt/gentoo/home/meow/gentoo && sudo chown -R 1000:100 /mnt/gentoo/home/meow/gentoo
cd /
sudo umount -R /mnt/gentoo
sudo cryptsetup close cryptroot
sudo mdadm --stop /dev/md0
sudo reboot
```

Expect systemd-boot, then a passphrase prompt, then a tty login. Secure Boot is still off here.

## 17. First boot: Secure Boot

Log in as meow on the tty. The guides are in `~/gentoo/` (`less ~/gentoo/install.md`).

Wi-Fi (iwd, no NetworkManager): `iwctl station wlan0 connect "<SSID>"`, passphrase at the prompt.

Reboot into the firmware (F1 on a ThinkPad). Set a Supervisor password, then Secure Boot →
"Reset to Setup Mode" (or "Clear All Secure Boot Keys"). Boot Gentoo, then:

```bash
sudo sbctl status                  # Setup Mode: Enabled
sudo sbctl enroll-keys -m          # -m keeps Microsoft certs: GPU/NVMe option ROMs need them
sudo sbctl verify                  # systemd-boot + UKI must be signed (spare/other files: ignore or sbctl sign)
```

Reboot, turn Secure Boot **on** in the firmware, then check:

```bash
sudo bootctl status | grep -i 'secure boot'    # enabled (user)
sudo cat /sys/kernel/security/lockdown         # informational: kernel lockdown mode
```

## 18. TPM2 + PIN unlock

The md device name can change after a reboot, so use the LUKS-UUID from step 12
(`sudo cryptsetup luksUUID /dev/md0`). Set `L` again in every new shell. It's new on every
install (the 2026-10-01 one doesn't apply any more).

```bash
L=/dev/disk/by-uuid/<LUKS-UUID>
```

Store the recovery key off this laptop (your password manager). Test it right away: paste
it at the `--test-passphrase` prompt. No output means it's valid.

```bash
sudo systemd-cryptenroll $L --recovery-key
sudo cryptsetup open --test-passphrase $L
```

The TPM releases the disk key only when all three hold:
- **PCR7** is the Secure Boot state (your keys). Booting anything signed by someone else
  changes it.
- **PCR11**, through the signed policy from step 11: a UKI you signed is running, and boot is
  still in the initrd.
- the **PIN** is right.

Paste the enroll command as **one line** (rule 3). Split up, it enrolls a token without a PIN or
without the PCR11 policy.

```bash
sudo systemd-cryptenroll $L --tpm2-device=auto --tpm2-pcrs=7 --tpm2-public-key=/etc/kernel/certs/pcr-public-key.pem --tpm2-public-key-pcrs=11 --tpm2-with-pin=yes
sudo systemd-cryptenroll $L                     # 0 password, 1 recovery, one tpm2 slot
sudo cryptsetup luksDump $L | grep -E 'systemd-|tpm2-pin|tpm2-hash-pcrs|tpm2-pubkey'   # pin: true, pcrs 7, pubkey-pcrs 11
```

Reboot: it asks for the PIN once. The passphrase still works as a fallback.

**Re-enroll whenever PCR7 changes:** a BIOS update, a Secure Boot db/dbx update (fwupd), or a
change to the sbctl keys. Also if you ever replace the PCR signing key from step 11. Kernel
updates don't need it: each new UKI carries its own PCR11 signature.

- Symptom: boot asks for "LUKS2 token PIN", then "TPM2 PIN", then the passphrase, and
  `journalctl -b | grep 'TPM policy does not match'` finds the error.
- Fix: unlock with the passphrase, then run this as one line:

```bash
sudo systemd-cryptenroll $L --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 --tpm2-public-key=/etc/kernel/certs/pcr-public-key.pem --tpm2-public-key-pcrs=11 --tpm2-with-pin=yes
```

## 19. Done

The install is finished when all of this is true:

- [ ] Boot asks for the **PIN** once and unlocks (passphrase as fallback)
- [ ] `sudo bootctl status` says Secure Boot: enabled (user)
- [ ] tty login as meow, `sudo true` asks for meow's password
- [ ] `ping -c2 gentoo.org` works over Wi-Fi

```bash
sudo bootctl status | grep -i 'secure boot'
sudo true && echo sudo-ok
ping -c2 gentoo.org
```

Continue in `~/gentoo/setup.md`. Its §0 clones dots, and after that the guides live in
`~/git/dots/gentoo/`.
