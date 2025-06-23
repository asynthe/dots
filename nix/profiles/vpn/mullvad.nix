{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.vpn.mullvad;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.vpn.mullvad.enable = mkEnableOption "Enable Mullvad VPN.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.mullvad-vpn = {
            enable = true;
            # pkgs.mullvad only provides the CLI tool.
            # pkgs.mullvad-vpn provices both CLI and GUI.
            package = pkgs.mullvad-vpn;
        };

        environment.persistence."/persist".directories = mkIf config.meta.disk.persistence.enable [
            "/etc/mullvad-vpn"
            "/var/cache/mullvad-vpn"
        ];
    };
}
