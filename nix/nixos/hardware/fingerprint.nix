{ ... }:
{
    flake.modules.nixos.fingerprint = { config, lib, ... }: {
        services.fprintd.enable = true;
        security.pam.services = {
            login.fprintAuth = true;
            sudo.fprintAuth = true;
        };

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/fprint" ];
    };
}
