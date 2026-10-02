# DRAFT — single-disk p1 for the Windows 11 dual boot. Not imported: import-tree
# skips `_`-prefixed paths. To switch: back up, `git mv` this over disko.nix,
# run disko from the installer. Rebuilding the running system with this would
# leave it unbootable — the RAID0 it expects to be gone is still there.
#
# nvme0 → NixOS (this file). nvme1 → Windows, which makes its own ESP.
# nvme1 is deliberately absent: a disko run must never be able to touch it.
{ inputs, ... }:
{
    flake.modules.nixos.p1-disko = { ... }:
    let
        disk0 = "/dev/nvme0n1";
        disk_encrypted = "nixcrypt";

        btrfsMountOpts = [ "compress=zstd:3" "noatime" "discard=async" ];
        luksSettings   = {
            allowDiscards    = true;
            bypassWorkqueues = true;
        };
        luksFormatArgs = [
            "--type"        "luks2"
            "--cipher"      "aes-xts-plain64"
            "--key-size"    "512"
            "--hash"        "sha256"
            "--pbkdf"       "argon2id"
            "--sector-size" "4096"
        ];
    in {
        imports = [ inputs.disko.nixosModules.disko ];

        boot.loader.efi.efiSysMountPoint = "/efi";

        # Windows lives on the other disk's ESP, which systemd-boot can't see on
        # its own. Get the handle from the EFI shell (`map -c`, then `ls HD1a1:`
        # until you find EFI/Microsoft) after Windows is installed. Until then,
        # F12 at the Lenovo splash picks it.
        #boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
        #boot.loader.systemd-boot.windows."11" = {
        #    title           = "Windows 11";
        #    efiDeviceHandle = "HD1a1";
        #};

        disko.devices.disk.nvme0 = {
            type = "disk";
            device = disk0;
            content.type = "gpt";
            content.partitions = {

                efi = {
                    priority = 1;
                    name = "efi";
                    size = "2G";
                    type = "EF00";
                    content.type = "filesystem";
                    content.format = "vfat";
                    content.mountpoint = "/efi";
                    content.mountOptions = [ "umask=0077" "defaults" "noatime" ];
                };

                luks = {
                    size = "100%";
                    content.type = "luks";
                    content.name = disk_encrypted;
                    content.settings = luksSettings;
                    content.extraFormatArgs = luksFormatArgs;
                    content.extraOpenArgs = [ "--timeout" "10" ];
                    content.content.type = "btrfs";
                    # label is load-bearing: the rollback in base/impermanence.nix
                    # mounts /dev/disk/by-label/nixos
                    content.content.extraArgs = [ "-L" "nixos" "-f" ];

                    content.content.postCreateHook = ''
                        MNTPOINT=$(mktemp -d)
                        mount -t btrfs "/dev/mapper/${disk_encrypted}" "$MNTPOINT"
                        trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                        btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                    '';

                    content.content.subvolumes = {
                        "/root" = {
                            mountpoint   = "/";
                            mountOptions = btrfsMountOpts;
                        };
                        "/nix" = {
                            mountpoint   = "/nix";
                            mountOptions = btrfsMountOpts;
                        };
                        "/home" = {
                            mountpoint   = "/home";
                            mountOptions = btrfsMountOpts;
                        };
                        "/persist" = {
                            mountpoint   = "/persist";
                            mountOptions = btrfsMountOpts;
                        };
                        "/log" = {
                            mountpoint   = "/var/log";
                            mountOptions = btrfsMountOpts;
                        };
                        "/snapshots" = {
                            mountpoint   = "/snapshots";
                            mountOptions = btrfsMountOpts;
                        };
                    };
                };
            };
        };
    };
}
