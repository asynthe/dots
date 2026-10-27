# p1 current disk layout (Gentoo, before NixOS install)

Captured 2026-10-26, for the live-ISO session doing the NixOS install. disko.nix
wipes and recreates everything below with fresh UUIDs — none of this needs to
be hardcoded into the flake. It's here so the live ISO can confirm it's about
to format the right two disks, in the right roles, before running disko.

## Disks

| device (this boot) | serial | model | size | role here |
| --- | --- | --- | --- | --- |
| /dev/nvme0n1 | 2427E8BA3FDF | CT4000P3PSSD8 | 3.6T | disk0 in disko.nix |
| /dev/nvme1n1 | 2427E8BA3FD2 | CT4000P3PSSD8 | 3.6T | disk1 in disko.nix |

`/dev/nvme0n1`/`nvme1n1` names are not guaranteed stable across boots or ISOs.
**Match by serial, not by name.** If the live ISO enumerates them in the
opposite order, swap `disk0`/`disk1` in `nix/hosts/p1/disko.nix` accordingly
— they're otherwise identical (same model, same size, both just RAID0
members), so getting the order "wrong" has no real consequence except which
one disko labels disk0 vs disk1 internally.

Boot USB (not part of the install): sda, TransMemory, serial
0022CFF6B8BBC990B32020ED — ignore, that's the live media itself.

## Current partition / RAID / LUKS layout (Gentoo), for reference only

```
nvme0n1 (2427E8BA3FDF)                 nvme1n1 (2427E8BA3FD2)
├─ nvme0n1p1  2G    EFI   UUID F943-4B9A    ├─ nvme1n1p1  2G  (no ESP used)
└─ nvme0n1p2  3.6T  RAID  UUID 937edfe7-7be2-8d98-963d-d36b9d8de3c6 (shared w/ below)
                                        └─ nvme1n1p2  3.6T  RAID  (same UUID, same array)
      └─ md0  7.3T  mdadm RAID0
            mdadm array UUID: 937edfe7:7be28d98:963dd36b:9d8de3c6
            array name: any:p1, created 2026-10-14, chunk size 512K
            └─ cryptroot  7.3T  LUKS, UUID b3435823-9eb2-4c72-8c05-c85b3a94c1d8
                  -> btrfs (Gentoo root, home, etc.)
```

None of these UUIDs (partition, mdadm array, LUKS) carry over — disko
generates new ones when it formats. This section exists purely so you can
tell, mid-install, whether you're looking at the OLD (Gentoo) layout or the
NEW (NixOS) one on an `lsblk`/`blkid` — if you see `937edfe7...` or
`b3435823...` again after disko supposedly ran, disko didn't actually wipe
that disk.

## What disko.nix expects going in

`nix/hosts/p1/disko.nix`: `disk0 = "/dev/nvme0n1"`, `disk1 = "/dev/nvme1n1"`,
GPT + 2G EFI (disk0 only) + mdadm RAID0 member (both disks, "100%" of
remaining space) -> LUKS2 (`aes-xts-plain64`, argon2id) -> btrfs with
subvolumes `/root /nix /home /persist /log /snapshots`. This matches the
current Gentoo layout's shape exactly (same two disks, same RAID0, same
LUKS2-over-btrfs), just rebuilt fresh.

## Before running disko

- Confirm via serial (table above) that what the ISO calls nvme0n1/nvme1n1
  really are the two 2427E8BA3FDF/3FD2 drives, not the boot USB or something
  else.
- `lsblk -o NAME,SIZE,SERIAL,MODEL,UUID` on the live ISO and diff against this
  file before confirming the disko run — if a mdadm UUID or LUKS UUID from
  this file still shows up, something didn't get wiped.
