{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.services.wine;
in {
    options.meta.services.wine.enable = mkOption {
        type = bool;
        default = false;
        description = ''
          Enable and set up Wine.
        '';
    };

    config = mkIf cfg.enable {

        # Wine configuration and packages
        # See more at https://wiki.nixos.org/wiki/Wine

        # Support for 32-bit apps.
        # Only supported for nvidia and also Mesa.
        hardware.opengl.driSupport32Bit = true;

        environment.systemPackages = builtins.attrValues {
            inherit (pkgs)

                # Frontends
                bottles #bottles-unwrapped
                #q4wine
      
                # Wine
                wine-wayland
                #wine-staging # With staging patches
                #wine # Support 32-bit only
                #wine64 # Support 64-bit only
      
                # Extras
                wineasio
                winetricks
            ;

            # Supports both 32 and 64-bit applications.
            inherit (pkgs.wineWowPackages) 
                waylandFull # With experimental Wayland support.
                #wayland # With experimental Wayland support.
                #unstableFull
                #unstable
                #stagingFull
                #staging
                #stableFull
                #stable
                #minimal
                #full
                #base
                #fonts # Microsoft replacement fonts by the Wine project.
            ;

            # Supports 64-bit only.
            inherit (pkgs.wine64Packages) 
                #waylandFull
                #wayland
                #unstableFull
                #unstable
                #stagingFull
                #staging
                #stableFull
                #stable
                #minimal
                #base
                #fonts # Microsoft replacement fonts by the Wine project.
            ;

            # Supports 32-bit only.
            inherit (pkgs.winePackages) 
                #waylandFull
                #wayland
                #unstableFull
                #unstable
                #stagingFull
                #staging
                #stableFull
                #stable
                #minimal
                #base
                #fonts # Microsoft replacement fonts by the Wine project.
            ;
        };
    };
}
