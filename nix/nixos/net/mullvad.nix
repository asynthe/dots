{ ... }:
{
    # TODO Make autostart
    flake.modules.nixos.mullvad = { config, lib, ... }: {
        services.mullvad-vpn.enable     = true;
        services.mullvad-vpn.gui.enable = true;
        #services.mullvad-vpn.enableEarlyBootBlocking = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/etc/mullvad-vpn" ];
    };
}
