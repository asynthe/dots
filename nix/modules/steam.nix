{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.steam;
in {
    options.sys.modules.steam = {
        enable = lib.mkEnableOption "Steam";
    };

    config = lib.mkIf cfg.enable {
        programs.steam.enable = true;
        programs.steam.remotePlay.openFirewall = true;
        programs.steam.dedicatedServer.openFirewall = true;
        programs.steam.localNetworkGameTransfers.openFirewall = true;
        programs.steam.gamescopeSession.enable = true;
        hardware.graphics.enable32Bit = true;

        environment.systemPackages = with pkgs; [
            protonup-ng
            protonup-rs
        ];
    };
}
