# Gentoo on p1: install

By hand from the LiveGUI USB. The Gentoo Handbook (amd64) covers anything not here; this file
wins on conflicts. It ends at a tty: encrypted RAID0, Secure Boot on, TPM + PIN unlock, Wi-Fi.
Everything after that is `setup.md`; every package is in `packages.md`.

Revised 2026-10-14: reinstall over Windows 11 on Intel RST RAID0.

## Machine

- ThinkPad P1 Gen 7, Core Ultra 7 155H (22 threads, no avx512), 30G RAM, TPM 2.0, UEFI
- 2× Crucial P3 4TB CT4000P3PSSD8: `nvme0n1` serial …8BA3FDF, `nvme1n1` serial …8BA3FD2
- Intel Arc (primary) + RTX 2000 Ada (offload), Wi-Fi BE200, Goodix fingerprint 27c6:6594

## Rules

1. Only `nvme0n1` + `nvme1n1` get touched. Run `lsblk` before every destructive command.
2. Passphrases, PINs and passwords go at prompts, never on a command line.
3. Paste long commands on **one line**, or keep every ` \`. A bare line break runs half a command.
4. 3 wrong `sudo` passwords lock the account for 10 minutes (`pam_faillock`). Wait, then
   `sudo faillock --user meow --reset`.

## Layout

| | |
|---|---|
| `nvme0n1p1` | 2G ESP, `/efi` |
| `nvme1n1p1` | 2G spare (unformatted) |
| `nvme0n1p2` + `nvme1n1p2` | md0 raid0 → LUKS2 aes-xts-512 → btrfs `@ @home @snapshots @log @distfiles @binpkgs` |
| Kernel | `gentoo-kernel`, built locally with its own module-signing key (nvidia under Secure Boot) |
| Boot | systemd-boot + signed UKI. Unlock: TPM2 (PCR7 + signed PCR11) + PIN; passphrase and recovery key as fallback |

Steps 0-8: live user, `sudo` per command. Steps 9-15: inside the chroot, already root, no `sudo`.
Step 16 on: `sudo` again.

## Before: from Windows

Windows sits on Intel RST (firmware RAID through VMD). This guide needs the two drives as plain
NVMe, with mdadm doing the RAID.

1. **Back up** `C:`. Steps 1-2 erase both drives.
2. **USB:** write `livegui-amd64-<date>.iso` (in `Downloads`, sha256 + gpg checked) with Rufus,
   in **DD mode**.
3. **Firmware** (F1 at the Lenovo logo):
   - Config → Storage: RAID / Intel RST (VMD) → plain **NVMe** (AHCI on some versions).
   - Security → Secure Boot: **off** (step 17 resets the keys).
   - Security → Security Chip: **Clear** (Windows owned the TPM; step 18 enrolls it fresh).
4. Boot the USB (F12).

## 0. Pre-flight

Wi-Fi: the panel applet or `nmtui`. A wrong date breaks TLS and gpg: `sudo date -s "YYYY-MM-DD HH:MM"`.

```bash
date
ping -c2 gentoo.org
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,LABEL
```

Expect `nvme0n1` and `nvme1n1` as two 3.6T disks. One ~7.3T `md126`, or `isw_raid_member` in
FSTYPE, means RST is still on in the firmware.

The guides (no git? `curl -fLO https://gitlab.com/asynthe/dots/-/raw/main/gentoo/install.md`):

```bash
git clone --depth 1 https://gitlab.com/asynthe/dots.git ~/dots && less ~/dots/gentoo/install.md
```

## 1. Wipe the Intel RST array

The RST metadata (IMSM) is still on the drives, and the live USB may have assembled it as
`md127` + `md126`.

```bash
cat /proc/mdstat
sudo mdadm --stop --scan
sudo mdadm --examine /dev/nvme0n1 /dev/nvme1n1 | grep -E 'Magic|Container'   # "Intel Raw RAID"
sudo mdadm --zero-superblock /dev/nvme0n1 /dev/nvme1n1
sudo wipefs -a /dev/nvme0n1 /dev/nvme1n1
sudo mdadm --examine /dev/nvme0n1 /dev/nvme1n1   # "No md superblock detected" on both
```

## 2. 4K LBA + secure erase

LBA format 1 = 4096 bytes. `--ses=1` is a User Data Erase (every block, Windows included). If a
drive rejects it ("Invalid Field"), run that line without `--ses=1`.

```bash
sudo nvme id-ns -H /dev/nvme0n1 | grep 'LBA Format'      # "LBA Format 1 : ... 4096"
sudo nvme id-ns -H /dev/nvme1n1 | grep 'LBA Format'
sudo nvme format /dev/nvme0n1 --lbaf=1 --ses=1
sudo nvme format /dev/nvme1n1 --lbaf=1 --ses=1
lsblk -o NAME,SIZE,LOG-SEC,PHY-SEC /dev/nvme0n1 /dev/nvme1n1   # LOG-SEC 4096
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

`--homehost=any`, or the array is named "livecd:p1" and later comes up as a foreign `md127`.

```bash
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 --chunk=512 --metadata=1.2 \
      --homehost=any --name=p1 /dev/nvme0n1p2 /dev/nvme1n1p2
cat /proc/mdstat
```

## 5. LUKS2

AES-256-XTS, 4K sectors, argon2id at 4 GiB. The passphrase takes ~3 s to unlock.

```bash
sudo cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 \
      --sector-size 4096 --hash sha512 --pbkdf argon2id \
      --pbkdf-memory 4194304 --pbkdf-parallel 4 --iter-time 3000 /dev/md0
```

`--persistent` stores discards and no-workqueue in the header:

```bash
sudo cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue \
      --persistent /dev/md0 cryptroot
sudo cryptsetup luksDump /dev/md0 | grep -E 'Flags|sector|Cipher'
```

## 6. Btrfs

`block-group-tree` keeps the block group index in its own small tree, so mounting 8TB doesn't
scan the whole disk. It can only be set at mkfs.

```bash
sudo mkfs.btrfs -L gentoo -O block-group-tree /dev/mapper/cryptroot
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
sudo btrfs inspect-internal dump-super /dev/mapper/cryptroot | grep -o BLOCK_GROUP_TREE
findmnt -R /mnt/gentoo
```

## 7. Stage3

`gpg --verify` must say "Good signature".

```bash
cd /mnt/gentoo
B=https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd
F=$(curl -s $B/latest-stage3-amd64-desktop-systemd.txt | grep -o 'stage3-[^ ]*\.tar\.xz' | head -1); echo $F
sudo wget $B/$F $B/$F.asc
gpg --import /usr/share/openpgp-keys/gentoo-release.asc
gpg --verify $F.asc $F
sudo tar xpf $F --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
sudo rm $F $F.asc
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

> Steps 9-15 happen **here**, at the `(chroot)` prompt. Editing `/etc` from a `gentoo@livecd`
> terminal changes the USB, not the new system.

```bash
source /etc/profile; export PS1="(chroot) $PS1"
ls /sys/firmware/efi/efivars | head -2      # must list files
```

## 9. Portage

```bash
emerge-webrsync
eselect profile set default/linux/amd64/23.0/desktop/systemd
```

`/etc/portage/make.conf`, replacing the whole file:

```bash
# Not -march=native: it reports different cache sizes per core type on this hybrid CPU, and
# gcc's PGO bootstrap aborts on that (bug #915389). This is native minus the cache params.
COMMON_FLAGS="-march=meteorlake -mabm -mshstk -mno-kl -mno-pconfig -mno-sgx -mno-widekl -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="-C target-cpu=native"
# ~2 GB RAM per job.
MAKEOPTS="-j15 -l22"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=22 --with-bdeps=y"
FEATURES="getbinpkg binpkg-request-signature parallel-fetch"
ACCEPT_LICENSE="*"
VIDEO_CARDS="intel nvidia"
INPUT_DEVICES="libinput"
USE="wayland pipewire vaapi vulkan dist-kernel systemd bluetooth secureboot modules-sign -gnome -kde"
GRUB_PLATFORMS=""
L10N="en es ja"
MICROCODE_SIGNATURES="-S"
SECUREBOOT_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
SECUREBOOT_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
MODULES_SIGN_KEY="/etc/kernel/certs/signing_key.pem"
MODULES_SIGN_CERT="/etc/kernel/certs/signing_key.pem"
```

This is the install-time file: stable, binhost, no LTO, so the install is fast. The real one is
`gentoo/portage/make.conf` in the dots (`~amd64`, LTO, `lto pgo`, build priorities): `setup.md`
§0 copies all of `gentoo/portage` over `/etc/portage` and rebuilds the system on it. Global
settings always go in `make.conf`, never in a second file.

Binhost (x86-64-v3), `/etc/portage/binrepos.conf/gentoobinhost.conf`:

```ini
[gentoobinhost]
priority = 1
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-v3/
```

```bash
getuto
```

CPU flags, before any other emerge. They go in `make.conf` only: the flags add up across files,
so a second list (`package.use`) would keep stale ones on. Packages whose flags differ from the
binhost's build from source; that's expected.

```bash
emerge --oneshot app-portage/cpuid2cpuflags
cpuid2cpuflags | sed 's/^.*CPU_FLAGS_X86: \(.*\)/CPU_FLAGS_X86="\1"/' >> /etc/portage/make.conf
tail -1 /etc/portage/make.conf       # CPU_FLAGS_X86="…"
portageq envvar CPU_FLAGS_X86        # same list
```

Expected (checked 2026-10-14): `aes avx avx2 avx_vnni bmi1 bmi2 f16c fma3 mmx mmxext pclmul
popcnt rdrand sha sse sse2 sse3 sse4_1 sse4_2 ssse3 vpclmulqdq`. If the chroot says otherwise,
the chroot is right.

`/etc/portage/package.use/p1` (fwupd `uefi` builds `fwupdx64.efi`, signed via `secureboot`):

```text
sys-kernel/installkernel dracut systemd systemd-boot uki ukify
sys-apps/systemd boot ukify cryptsetup tpm
sys-fs/cryptsetup argon2
media-video/pipewire sound-server
x11-drivers/nvidia-drivers wayland powerd
sys-apps/fwupd uefi
```

## 10. Base config

```bash
echo p1 > /etc/hostname
ln -sf ../usr/share/zoneinfo/America/Santiago /etc/localtime
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

The PIN and passphrase are typed with the initramfs keymap, so set it before the kernel:

```bash
echo 'KEYMAP=us' > /etc/vconsole.conf
systemd-machine-id-setup
```

## 11. Keys

Secure Boot keys (enrolled in step 17):

```bash
emerge -av app-crypt/sbctl app-crypt/sbsigntools
sbctl create-keys
ls /var/lib/sbctl/keys/db/       # db.key db.pem
```

Module-signing key (the kernel trusts it, nvidia gets signed with it):

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

PCR signing key. Every UKI carries a signed PCR11 policy, valid only in the initrd. Step 18 binds
the disk to it: the TPM unseals only under your UKI, before boot leaves the initrd, so a swapped
root can't ask for the key. Kernel updates need no re-enroll. (systemd 262 also needs it for
NvPCRs, issue #43848.) It stays out of `/etc/systemd/`, so only step 18 binds to it.

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /etc/kernel/certs/pcr-private-key.pem
openssl pkey -in /etc/kernel/certs/pcr-private-key.pem -pubout -out /etc/kernel/certs/pcr-public-key.pem
chmod 600 /etc/kernel/certs/pcr-private-key.pem
```

A second key signs every boot phase, for credentials (systemd's NvPCR anchor, `systemd-creds`)
that must unseal after the initrd too; the disk key above stays initrd-only:

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /etc/kernel/certs/pcr-creds-private-key.pem
openssl pkey -in /etc/kernel/certs/pcr-creds-private-key.pem -pubout -out /etc/kernel/certs/pcr-creds-public-key.pem
chmod 600 /etc/kernel/certs/pcr-creds-private-key.pem
```

`/etc/kernel/uki.conf`:

```ini
[UKI]
SecureBootSigningTool=sbsign
SecureBootPrivateKey=/var/lib/sbctl/keys/db/db.key
SecureBootCertificate=/var/lib/sbctl/keys/db/db.pem
SignInitrdPCRs=yes
OSRelease=@/run/kernel/os-release-uki
# .pcrpkey: what credentials (NvPCR anchor, systemd-creds) get sealed to. Must be the
# all-phases key, or they can't be unsealed after the initrd.
PCRPKey=/etc/kernel/certs/pcr-creds-public-key.pem

# Credentials: every phase. First on purpose: SignInitrdPCRs= signs its extra "initrd"-only
# policy with the first section's key, and systemd initializes its NvPCRs (in the initrd) only
# with that signature from the .pcrpkey key above. With p1 first: "Couldn't find signature for
# this PCR bank, PCR index and public key" and 3 failed units every boot (2026-10-15).
# Phases= must be spelled out: once one section sets it, ukify needs it in all ("--phases=
# specifications must match --pcr-private-key="), and the kernel install fails without
# deploying a UKI. These are systemd-measure's defaults.
[PCRSignature:creds]
PCRPrivateKey=/etc/kernel/certs/pcr-creds-private-key.pem
PCRPublicKey=/etc/kernel/certs/pcr-creds-public-key.pem
Phases=enter-initrd enter-initrd:leave-initrd enter-initrd:leave-initrd:sysinit enter-initrd:leave-initrd:sysinit:ready

# Disk unlock (step 18): initrd only.
[PCRSignature:p1]
PCRPrivateKey=/etc/kernel/certs/pcr-private-key.pem
PCRPublicKey=/etc/kernel/certs/pcr-public-key.pem
Phases=enter-initrd
```

Boot menu titles per kernel (`Gentoo Linux (7.2.8)`) instead of identical baselayout versions:

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

## 12. Boot config

`/etc/dracut.conf.d/p1.conf`:

```bash
add_dracutmodules+=" mdraid crypt btrfs systemd tpm2-tss "
hostonly="yes"
compress="zstd"
```

UUIDs. The stage3 has no mdadm or cryptsetup yet, so run these in a **second, non-chroot
terminal**:

```bash
sudo mdadm --detail /dev/md0 | grep UUID                    # ARRAY-UUID (with colons)
sudo cryptsetup luksUUID /dev/md0                           # LUKS-UUID
sudo mdadm --detail --scan | sudo tee -a /mnt/gentoo/etc/mdadm.conf
```

Back in the chroot:

```bash
blkid /dev/mapper/cryptroot /dev/nvme0n1p1      # BTRFS-UUID, ESP-UUID
tail -1 /etc/mdadm.conf                         # ARRAY /dev/md0 metadata=1.2 UUID=...
```

`/etc/kernel/cmdline`, one line:

```text
rd.md.uuid=<ARRAY-UUID> rd.luks.name=<LUKS-UUID>=cryptroot rd.luks.options=tpm2-device=auto root=/dev/mapper/cryptroot rootflags=subvol=@ rw nvidia-drm.modeset=1 nvidia-drm.fbdev=1 init_on_free=1 quiet
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

```bash
emerge -avuDN @world
emerge -av sys-apps/systemd          # makes sure the boot/secureboot build is in place
bootctl install
```

`/efi/loader/loader.conf`:

```text
timeout 3
editor no
```

Order matters:
1. dracut's tools, or it fails with "Module 'btrfs' / 'tpm2-tss' cannot be installed". The `rm`
   keeps **your** `mdadm.conf` (with the ARRAY line).
2. The kernel (compiles locally, 30-60 min).
3. Firmware + microcode **after** the kernel: their postinst rebuilds the UKI, which fails with no
   kernel and stops the emerge.

```bash
emerge -av sys-fs/btrfs-progs sys-fs/mdadm sys-fs/cryptsetup app-crypt/tpm2-tss app-crypt/tpm2-tools
rm /etc/._cfg0000_mdadm.conf
emerge -av \
  sys-kernel/gentoo-kernel \
  sys-firmware/sof-firmware \
  sys-fs/dosfstools sys-apps/nvme-cli sys-apps/zram-generator \
  net-wireless/iwd net-wireless/bluez app-shells/zsh app-admin/sudo \
  dev-vcs/git app-editors/neovim net-misc/rsync app-eselect/eselect-repository \
  sys-apps/fwupd sys-power/power-profiles-daemon sys-boot/efibootmgr
emerge -av sys-kernel/linux-firmware sys-firmware/intel-microcode
ls -d /var/db/pkg/sys-kernel/linux-firmware-* /var/db/pkg/sys-firmware/intel-microcode-*   # both exist
```

- `dracut[E]: Module 'X' cannot be installed`: install the missing tool, then
  `emerge --config sys-kernel/gentoo-kernel` (rebuilds initramfs + UKI, no recompile).
- If an emerge stops partway, the rest of its list wasn't installed: rerun it.

## 14. Verify the boot chain (don't skip)

One UKI (`<machine-id>-<kver>-gentoo-dist.efi`), three "Signature verification OK", and a command
line matching `/etc/kernel/cmdline` (+ `systemd.machine_id=…`).

```bash
U=$(ls /efi/EFI/Linux/*.efi); echo $U
sbverify --cert /var/lib/sbctl/keys/db/db.pem $U
sbverify --cert /var/lib/sbctl/keys/db/db.pem /efi/EFI/systemd/systemd-bootx64.efi
sbverify --cert /var/lib/sbctl/keys/db/db.pem /efi/EFI/BOOT/BOOTX64.EFI
lsinitrd $U | sed -n '/^Command line:/,/^====/p'
lsinitrd $U | grep -E 'GenuineIntel.bin|bin/btrfs$|bin/mdadm$|bin/systemd-cryptsetup$|token-systemd-tpm2|libtss2-esys'
lsinitrd -f etc/mdadm.conf $U              # ARRAY /dev/md0 … UUID=<ARRAY-UUID>
lsinitrd -f etc/vconsole.conf $U           # KEYMAP=us
objdump -h $U | grep -E 'pcrsig|pcrpkey'   # signed PCR11 policy + its key
bootctl list --no-pager | grep title       # Gentoo Linux (<kernel version>)
bootctl status                             # loader + ESP found; Secure Boot off is fine for now
```

The `lsinitrd | grep` must show all 6: `GenuineIntel.bin`, `btrfs`, `mdadm`, `systemd-cryptsetup`,
`libcryptsetup-token-systemd-tpm2.so`, `libtss2-esys`. Missing one: install its package, then
`emerge --config sys-kernel/gentoo-kernel`.

EFI entries:

```bash
efibootmgr
```

- Delete "Windows Boot Manager" and any old Linux Boot Manager: `efibootmgr -b XXXX -B`.
- Keep the new "Linux Boot Manager" and the Lenovo FvFile/VenMsg entries.
- "Fallback Linux Boot Manager" may point at a missing file. Harmless; delete it if you like.
- BootOrder must start with the new Linux Boot Manager (`efibootmgr | head -8`).

## 15. Services + users

```bash
systemctl preset-all --preset-mode=enable-only
systemctl enable iwd systemd-resolved systemd-timesyncd fstrim.timer bluetooth power-profiles-daemon
```

iwd on its own (no NetworkManager; the quickshell bar reads iwd over D-Bus).
`/etc/iwd/main.conf`:

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

meow: UID 1000, group `users` (100). sudo asks for meow's password (setup.md §6 adds the
fingerprint). The wheel rule goes in its own file, not in `/etc/sudoers`: a sudo update ships a
new `/etc/sudoers`, and accepting it in `dispatch-conf` silently drops an edit made there (it
happened on 2026-10-15: "user NOT in sudoers"; `su -` with the root password got back in).

```bash
useradd -m -u 1000 -g users -G wheel,video,audio,input,render -s /bin/zsh meow
passwd meow
passwd
mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
grep -n includedir /etc/sudoers     # @includedir /etc/sudoers.d
visudo -c
```

Last in the chroot (it breaks DNS here; the stub exists once systemd runs):

```bash
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

## 16. Leave + reboot

```bash
exit
sudo cp -r ~/dots/gentoo /mnt/gentoo/home/meow/gentoo && sudo chown -R 1000:100 /mnt/gentoo/home/meow/gentoo
cd /
sudo umount -R /mnt/gentoo
sudo cryptsetup close cryptroot
sudo mdadm --stop /dev/md0
sudo reboot
```

Expect systemd-boot, the passphrase prompt, then a tty login.

## 17. Secure Boot

Log in as meow (guides in `~/gentoo/`). Wi-Fi: `iwctl station wlan0 connect "<SSID>"`.

Firmware (F1): set a **Supervisor password**, then Secure Boot → "Reset to Setup Mode". Boot
Gentoo:

```bash
sudo sbctl status                  # Setup Mode: Enabled
sudo sbctl enroll-keys -m          # -m keeps Microsoft certs: GPU/NVMe option ROMs need them
sudo sbctl verify                  # systemd-boot + UKI signed
```

Reboot, turn Secure Boot **on** in the firmware, then:

```bash
sudo bootctl status | grep -i 'secure boot'    # enabled (user)
```

## 18. TPM2 + PIN

Use the LUKS-UUID (md names can change): `sudo cryptsetup luksUUID /dev/md0`. Set `L` in every
new shell.

```bash
L=/dev/disk/by-uuid/<LUKS-UUID>
```

Recovery key: store it off the laptop, then test it at the prompt (no output = valid).

```bash
sudo systemd-cryptenroll $L --recovery-key
sudo cryptsetup open --test-passphrase $L
```

The TPM unseals only with your Secure Boot keys (PCR7), your signed UKI still in the initrd
(PCR11), and the PIN. **One line** (rule 3), or it enrolls without the PIN or the PCR11 policy:

```bash
sudo systemd-cryptenroll $L --tpm2-device=auto --tpm2-pcrs=7 --tpm2-public-key=/etc/kernel/certs/pcr-public-key.pem --tpm2-public-key-pcrs=11 --tpm2-with-pin=yes
sudo systemd-cryptenroll $L                     # 0 password, 1 recovery, one tpm2
sudo cryptsetup luksDump $L | grep -E 'systemd-|tpm2-pin|tpm2-hash-pcrs|tpm2-pubkey'   # pin true, pcrs 7, pubkey-pcrs 11
```

Reboot: one PIN prompt.

**Re-enroll when PCR7 changes** (BIOS update, db/dbx update via fwupd, new sbctl keys) or if you
replace the PCR signing key. Kernel updates don't need it. Symptom: "LUKS2 token PIN", then "TPM2
PIN", then the passphrase; `journalctl -b | grep 'TPM policy does not match'`. Unlock with the
passphrase, then:

```bash
sudo systemd-cryptenroll $L --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 --tpm2-public-key=/etc/kernel/certs/pcr-public-key.pem --tpm2-public-key-pcrs=11 --tpm2-with-pin=yes
```

## 19. Done

- [ ] Boot asks for the **PIN** once (passphrase as fallback)
- [ ] Secure Boot: enabled (user)
- [ ] `sudo true` asks for meow's password
- [ ] Wi-Fi works

```bash
sudo bootctl status | grep -i 'secure boot'
sudo true && echo sudo-ok
ping -c2 gentoo.org
```

Continue in `~/gentoo/setup.md`.
