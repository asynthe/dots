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

        # ASSERTION
        # Please set sys.modules.networking.backend = "networkmanager" or "iwd"

        # NetworkManager
        # networking.networkmanager.enable = true;
        # TODO mkIf laptop (?)
        # networking.networkmanager = {
        #     ethernet.macAddress = "random";
        #     wifi.scanRandMacAddress = true;
        #     wifi.macAddress = "random";
        # };
        # environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/etc/NetworkManager/system-connections" ];

        # iwd
        networking.networkmanager.enable = false;
        networking.wireless.iwd = {
            enable = true; # for `impala` command
            settings.Settings.AutoConnect = true; # TODO ?
            settings.General.EnableNetworkConfiguration = true;
            settings.Network.NameResolvingService = "systemd";

            # TODO mkIf laptop (?)
            #settings.Network.EnableIPv6 = true;
            #settings.Network.RoutePriorityOffset = 300;
            #settings.General.AddressRandomization = "network";
            #settings.General.AddressRandomizationRange = "full";
        };
        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/iwd" ];

        # TODO Is this setup because of Tailscale (?)
        services.resolved = {
            enable = true;
            settings.Resolve.FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
        };
        networking.interfaces.tailscale0.useDHCP = false;

        # TODO Get iproute2, macchanger, test this for mac randomization
        #services.udev.extraRules = ''
        #ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", \
        #RUN+="${pkgs.iproute2}/bin/ip link set dev $name address $(${pkgs.macchanger}/bin/macchanger -r $name | awk '/New MAC/{print $3}')"
        #'';
    };
}
