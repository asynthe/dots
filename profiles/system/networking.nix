{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.system.networking;
in {
    options.meta.system.networking.type = mkOption {
        type = str;
        default = config.meta.system.type;
        description = "Enable and set up a Network Manager configuration.";
    };

    config = mkMerge [
        (mkIf (cfg.type == "server") {
            networking.networkmanager.enable = true;
        })
        (mkIf (cfg.type == "laptop") {
            networking.networkmanager = {
                enable = true;
                ethernet.macAddress = "random";
                wifi.scanRandMacAddress = true;
                wifi.macAddress = "random"; # permanent, preserve, random, stable.
            };
        })

    ];
}
