{ ... }:
{
    flake.modules.nixos.steam = { pkgs, ... }: {
        programs.steam.enable = true;
        programs.steam.remotePlay.openFirewall = true;
        programs.steam.dedicatedServer.openFirewall = true;
        programs.steam.localNetworkGameTransfers.openFirewall = true;
        programs.steam.gamescopeSession.enable = true;
        hardware.graphics.enable32Bit = true;

        environment.systemPackages = with pkgs; [
            gamemode
            protontricks
            protonup-ng
            protonup-rs
            #steamtinkerlaunch
        ];
    };
}
