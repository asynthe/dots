{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.networking;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.networking = {
        enable = lib.mkEnableOption "Networking";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ macchanger impala ];
        networking.nftables.enable = true;

        # TODO Add a sys.modules.networking.backend option ("networkmanager" or "iwd") with an assertion

        # iwd
        networking.networkmanager.enable = false;
        networking.wireless.iwd = {
            enable = true; # for `impala` command
            settings.Settings.AutoConnect = true; # TODO ?
            settings.General.EnableNetworkConfiguration = true;
            settings.Network.NameResolvingService = "systemd";

            # TODO mkIf laptop: IPv6, RoutePriorityOffset, address randomization
        };
        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/iwd" ];

        # TODO Is this setup because of Tailscale (?)
        services.resolved = {
            enable = true;
            settings.Resolve.FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
        };
        networking.interfaces.tailscale0.useDHCP = false;

        # TODO udev rule with iproute2 + macchanger for ethernet mac randomization
    };
}
