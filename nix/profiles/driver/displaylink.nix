{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.driver;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.driver.displaylink = mkOption {
        type = bool;
        default = false;
        description = "Enable drivers for Display Link connections.";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.displaylink {
        # Displaylink driver for multiple monitors
        # See more at https://wiki.nixos.org/wiki/Displaylink

        # Remember to add the drivers to the nix store
        # https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu

        services.xserver = {
            videoDrivers = [ "displaylink" "modesetting" ];
            #sessionCommands = ''
              #${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
            #'';
        };
    };
}
