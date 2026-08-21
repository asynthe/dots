# TODO Make autostart
# End of page https://wiki.nixos.org/wiki/Mullvad_VPN

{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.mullvad-vpn;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.mullvad-vpn = {
        enable = lib.mkEnableOption "Mullvad VPN";
    };

    config = lib.mkIf cfg.enable {
        services.mullvad-vpn.enable = true;
        services.mullvad-vpn.gui.enable = true;
        #services.mullvad-vpn.enableEarlyBootBlocking = true;

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/etc/mullvad-vpn" ];
    };
}
