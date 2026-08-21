{ ... }:
{
    flake.modules.nixos.network = { config, lib, pkgs, ... }: {
        environment.systemPackages = with pkgs; [ macchanger impala ];
        networking.nftables.enable = true;

        # TODO Add a backend aspect split ("networkmanager" vs "iwd")

        # iwd
        networking.networkmanager.enable = false;
        networking.wireless.iwd = {
            enable = true; # for `impala` command
            settings.Settings.AutoConnect = true; # TODO ?
            settings.General.EnableNetworkConfiguration = true;
            settings.Network.NameResolvingService = "systemd";

            # TODO on laptops: IPv6, RoutePriorityOffset, address randomization
        };
        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/iwd" ];

        # TODO Is this setup because of Tailscale (?)
        services.resolved = {
            enable = true;
            settings.Resolve.FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
        };
        networking.interfaces.tailscale0.useDHCP = false;

        # TODO udev rule with iproute2 + macchanger for ethernet mac randomization
    };
}
