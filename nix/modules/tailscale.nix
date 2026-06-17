{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.tailscale;
    impermanenceCfg = config.sys.modules.impermanence;
in {
    options.sys.modules.tailscale = {
        enable = lib.mkEnableOption "Tailscale";
    };

    config = lib.mkIf cfg.enable {
        services.tailscale.enable = true;
        networking.firewall = {
            enable = true;
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
        };

        networking.nftables.enable = true;
        systemd.services.tailscaled.serviceConfig.Environment = [ 
            "TS_DEBUG_FIREWALL_MODE=nftables" 
        ];

        # Quicker boot
        systemd.network.wait-online.enable = false;
        boot.initrd.systemd.network.wait-online.enable = false;

        # TODO option for /persist
        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/tailscale" ];
    };
}
