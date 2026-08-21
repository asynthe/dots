let
    disk = "/dev/nvme1n1";
    disk_encrypted = "nixcrypt";
    btrfs_device = "/dev/mapper/${disk_encrypted}";
in {
    
    # ─────────────── Impermanence ───────────────
    # TODO Move the imports here and gate them on the impermanence option
    fileSystems = {
        "/persist".neededForBoot = true;
        "/var/log".neededForBoot = true;
    };

    environment.persistence."/persist" = {
        hideMounts = true;
        files = [
            "/etc/machine-id"
            "/var/lib/systemd/random-seed"
            "/etc/adjtime" # Hardware clock # TODO Check
            #"/root/.bash_history"
            #"/etc/zfs/zpool.cache"

            # agenix
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
        ];
        directories = [
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
            "/var/lib/bluetooth" # TODO bluetooth.nix
            "/var/lib/sbctl" # TODO secure_boot.nix
            "/var/lib/fprint" # TODO fprint.nix

            # TODO Move /var/lib/tailscale to tailscale.nix and /etc/secureboot to secure.nix
        ];
    };

    # ─────────────── Disko ───────────────
    disko.devices = {
        disk.main = {
            type = "disk";
            device = "${disk}";
            content.type = "gpt";
            content.partitions = {

                # EFI
                boot = {
                    priority = 1;
                    name = "efi";
                    size = "1G";
                    type = "EF00";
                    content.type = "filesystem";
                    content.format = "vfat";
                    content.mountpoint = "/efi";
                    content.mountOptions = [ "defaults" "noatime" ];
                };

                main = {
                    size = "100%";
                    label = "NIXCRYPT";
                    content.type = "luks";
                    content.name = "${disk_encrypted}";
                    content.settings = {
                        allowDiscards    = true; # SSD trim
                        bypassWorkqueues = true; # SSD latency
                    };
                    content.extraFormatArgs = [
                        "--type"        "luks2"
                        "--cipher"      "aes-xts-plain64"
                        "--key-size"    "512"
                        "--hash"        "sha256"
                        "--pbkdf"       "argon2id"
                        "--sector-size" "4096"
                    ];
                    content.extraOpenArgs = [ "--timeout" "10" ];
                    content.content.type = "btrfs";
                    content.content.extraArgs = [ "-L" "nixos" "-f" ];

                    # Create snapshot regardless of if impermanence is enabled
                    # This way we can enable impermanence later on if we want
                    content.content.postCreateHook = ''
MNTPOINT=$(mktemp -d)
mount -t btrfs "/dev/mapper/${disk_encrypted}" "$MNTPOINT"
trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                    '';

                    content.content.subvolumes = {

                        # Wiped on every boot via initrd script
                        "/root" = {
                            mountpoint = "/";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                        "/nix" = {
                            mountpoint = "/nix";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                        "/home" = {
                            mountpoint = "/home";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                        "/persist" = {
                            mountpoint = "/persist";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                        "/log" = {
                            mountpoint = "/var/log";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                        "/snapshots" = {
                            mountpoint = "/snapshots";
                            mountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
                        };
                    };
                };
            };
        };
    };
}
