{ ... }:
{
    flake.modules.nixos.ssh = { config, lib, ... }: {
        config = let
            hasKeys = lib.any
                (name: config.users.users.${name}.openssh.authorizedKeys.keys != [])
                config.sys.admins;
        in {
            services.openssh = {
                enable = true;
                settings = {
                    PasswordAuthentication       = !hasKeys;
                    KbdInteractiveAuthentication = !hasKeys;
                    PermitRootLogin              = "no";
                };
            };
        };
    };
}
