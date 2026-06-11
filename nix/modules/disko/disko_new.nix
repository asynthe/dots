let
    disk0          = "/dev/nvme0n1";
    disk1          = "/dev/nvme1n1";
    disk_encrypted = "nixcrypt";
    btrfsMountOpts = [ "compress=zstd:3" "noatime" "discard=async" ];
    luksSettings   = {
        allowDiscards    = true; # SSD trim — propagates through mdadm + LUKS
        bypassWorkqueues = true; # SSD latency optimisation
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

    # ─────────────── Disko ───────────────
    disko.devices = {

        # ── nvme0n1: ESP + first RAID-0 member ───────────────────────────────
        disk.nvme0 = {
            type   = "disk";
            device = disk0;
            content.type = "gpt";
            content.partitions = {

                efi = {
                    priority = 1;
                    name     = "efi";
                    size     = "1G";
                    type     = "EF00";
                    content.type         = "filesystem";
                    content.format       = "vfat";
                    content.mountpoint   = "/efi";
                    content.mountOptions = [ "umask=0077" "defaults" "noatime" ];
                };

                mdadm = {
                    size         = "100%";   # remainder after ESP
                    content.type = "mdadm";
                    content.name = "nixraid";
                };
            };
        };

        # ── nvme1n1: second RAID-0 member (no ESP needed) ────────────────────
        disk.nvme1 = {
            type   = "disk";
            device = disk1;
            content.type = "gpt";
            content.partitions = {

                mdadm = {
                    size         = "100%";
                    content.type = "mdadm";
                    content.name = "nixraid";
                };
            };
        };

        # ── mdadm array → LUKS2 → btrfs ─────────────────────────────────────
        # level 0 = RAID-0 stripe.  Both members above share the name "nixraid"
        # so disko assembles them into /dev/md/nixraid before opening LUKS.
        mdadm.nixraid = {
            type  = "mdadm";
            level = 0;

            content.type            = "luks";
            content.name            = disk_encrypted;
            content.settings        = luksSettings;
            content.extraFormatArgs = luksFormatArgs;
            content.extraOpenArgs   = [ "--timeout" "10" ];

            content.content.type      = "btrfs";
            content.content.extraArgs = [ "-L" "nixos" "-f" ];

            # Snapshot /root immediately after the filesystem is created.
            # The initrd rollback service restores from this on every boot.
            # Keep root-blank read-only (-r) so it can never be accidentally modified.
            content.content.postCreateHook = ''
                MNTPOINT=$(mktemp -d)
                mount -t btrfs "/dev/mapper/${disk_encrypted}" "$MNTPOINT"
                trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                btrfs subvolume snapshot -r "$MNTPOINT/root" "$MNTPOINT/root-blank"
            '';

            content.content.subvolumes = {

                # Wiped on every boot by the initrd rollback service in system.nix.
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
