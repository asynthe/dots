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
        networking.nftables.enable = true;
        systemd.network.wait-online.enable = false; 
        boot.initrd.systemd.network.wait-online.enable = false;
        networking.firewall = {
            enable = true;
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
        };
        systemd.services.tailscaled.serviceConfig.Environment = [ 
            "TS_DEBUG_FIREWALL_MODE=nftables" 
        ];

        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/tailscale" ];
    };
}
