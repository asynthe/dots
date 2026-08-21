{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.incus;
in {
    options.sys.modules.incus = {
        enable = lib.mkEnableOption "Incus";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.incus.enable = true;
        networking.nftables.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "incus-admin" ];
    };
}
