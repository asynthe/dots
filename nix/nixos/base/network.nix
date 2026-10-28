{ ... }:
{
    flake.modules.nixos.network = { config, lib, pkgs, ... }: {
        environment.systemPackages = with pkgs; [ macchanger impala ];
        networking.nftables.enable = true;

        networking.networkmanager.enable = false;
        networking.wireless.iwd = {
            enable = true;
            settings.Settings.AutoConnect = true;
            settings.General.EnableNetworkConfiguration = true;
            settings.Network.NameResolvingService = "systemd";
        };
        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/iwd" ];

        services.resolved = {
            enable                       = true;
            settings.Resolve.FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
        };
        networking.interfaces.tailscale0.useDHCP = false;
    };
}
