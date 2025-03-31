{ pkgs, ... }: {

    #boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
    boot.supportedFilesystems = [ "ext4" "xfs" "vfat" ];
    environment.binsh = "${pkgs.dash}/bin/dash"; # Change sh for dash.
    services.gvfs.enable = true; # Needed for almost all file explorers.

    # Polkit
    security.polkit.enable = true;
    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
            ntfs3g
            polkit
        ;
    };
}
