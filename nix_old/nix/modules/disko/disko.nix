let
    disk0 = "/dev/nvme0n1";
    disk1 = "/dev/nvme1n1";
    disk_raid = "nixraid";
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

    # TODO Move?
    boot.loader.efi.efiSysMountPoint = "/efi";
    virtualisation.docker.storageDriver = "btrfs";

    # Suppress mdadm warning; I don't use this
    boot.swraid.mdadmConf = ''
      MAILADDR=nobody@nowhere
    '';

    # ─────────────── Disko ───────────────
    disko.devices = {

        # First RAID0 Disk
        disk.nvme0 = {
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

                mdadm = {
                    size = "100%";
                    content.type = "mdraid";
                    content.name = disk_raid;
                };
            };
        };

        # Second RAID0 Disk
        disk.nvme1 = {
            type = "disk";
            device = disk1;
            content.type = "gpt";
            content.partitions = {

                mdadm = {
                    size = "100%";
                    content.type = "mdraid";
                    content.name = disk_raid;
                };
            };
        };

        # RAID0 MDADM SETUP
        mdadm.${disk_raid} = {
            type = "mdadm";
            level = 0;

            content.type = "luks";
            content.name = disk_encrypted;
            content.settings = luksSettings;
            content.extraFormatArgs = luksFormatArgs;
            content.extraOpenArgs = [ "--timeout" "10" ];
            #content.askPassword = true; # TODO ?
            content.content.type = "btrfs";
            content.content.extraArgs = [ "-L" "nixos" "-f" ];

            # Create a blank snapshot when creating system for impermanence.
            postCreateHook = ''
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
}
