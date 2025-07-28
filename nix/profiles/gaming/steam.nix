# TODO
# ADD STUFF FROM VIMJOYERS VIDEO
# ADD MORE CONFIGURATION AND OPTIONS (XBOX CONTROLLER?)

{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.gaming;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.gaming.steam = mkEnableOption "Enable Steam and gaming-related packages like Proton.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.steam {

        programs.steam = {
            enable = true;
            extest.enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true; # Open ports for Steam Remote Play.
            localNetworkGameTransfers.openFirewall = true;
            dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server.
            extraCompatPackages = with pkgs; [
                proton-ge-bin
            ];
        };

        programs.steam.protontricks.enable = true;
        environment.sessionVariables = {
            STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.meta.system.user}/.steam/root/compatibilitytools.d";
        };

        environment.systemPackages = with pkgs; [
            pkgsi686Linux.gperftools # temp fix

            mangohud
            protonup-ng # ProtonGE
            #steam-tui
            #gamescope
            steamtinkerlaunch

	        #steamPackages.steamcmd
	        #steamPackages.steam-runtime
	        #steamPackages.steam-runtime-wrapped
        ];
    };
}
