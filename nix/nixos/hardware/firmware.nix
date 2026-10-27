{ ... }:
{
    flake.modules.nixos.firmware = { config, lib, ... }: {
        services.fwupd.enable = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/fwupd" ];
    };
}
