{ ... }:
{
    flake.modules.nixos.tailscale = { config, lib, ... }: {
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

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/tailscale" ];
    };

    # TODO Make autostart
    # End of page https://wiki.nixos.org/wiki/Mullvad_VPN
    flake.modules.nixos.mullvad = { config, lib, ... }: {
        services.mullvad-vpn.enable = true;
        services.mullvad-vpn.gui.enable = true;
        #services.mullvad-vpn.enableEarlyBootBlocking = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/etc/mullvad-vpn" ];
    };
}
