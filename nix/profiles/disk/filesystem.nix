{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.disk;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.disk.filesystem = mkOption {
        type = nullOr str;
        default = null;
        description = "Filesystem to be used.";
    };

    imports = [
        #./disko/bcachefs.nix
        ./disko/btrfs.nix
        #./disko/ext4.nix
        #./disko/xfs.nix
        #./disko/zfs.nix
    ];

    # ───────────────────────── Configuration ─────────────────────────
    config = {
        # I want to set up assertions that only those specified filesystems can be used
        # If null or a filesystem that doesn't exists is put, then stop the process.

        assertions = [
            {
                assertion = cfg.filesystem != null;
                message = "You must specify a filesystem for disko!";
            }
            #{
                #assertion = cfg.filesystem != [
                    #"bcachefs"
                    #"btrfs"
                    #"ext4"
                    #"xfs"
                    #"zfs"
                #];
                #message = "The specified filesystem is not valid. Please choose from: bcachefs, btrfs, ext4, xfs and zfs.";
            #}
        ];
    };
}
