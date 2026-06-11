# TODO Make autostart
# End of page https://wiki.nixos.org/wiki/Mullvad_VPN

{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.mullvad-vpn;
    impermanenceCfg = config.sys.modules.impermanence;
in {
    options.sys.modules.mullvad-vpn = {
        enable = lib.mkEnableOption "Mullvad VPN";
    };

    config = lib.mkIf cfg.enable {
        services.mullvad-vpn.enable = true;
        services.mullvad-vpn.package = pkgs.mullvad-vpn; # gui

        # TODO set this variable, maybe in impermanence file
        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/etc/mullvad-vpn" ];
    };
}
