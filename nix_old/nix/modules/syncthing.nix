{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.syncthing;
in {
    options.sys.modules.syncthing = {
        enable = lib.mkEnableOption "Syncthing";
    };

    config = lib.mkIf cfg.enable {
        services.syncthing.enable = true;
        services.syncthing.openDefaultPorts = true;
        networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}
