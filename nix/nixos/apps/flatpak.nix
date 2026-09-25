{ ... }:
{
    flake.modules.nixos.flatpak = { config, lib, ... }: {
        services.flatpak.enable = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/flatpak" ];
    };
}
