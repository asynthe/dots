{ ... }:
{
    flake.modules.nixos.ssh = { config, lib, ... }: {
        # Passwords stay enabled until a key can actually get in, so adding the
        # first key is what locks the door -- never a rebuild that locks you out.
        options.sys.ssh.authorizedKeys = lib.mkOption {
            type    = lib.types.listOf lib.types.str;
            default = [];
            example = [ "ssh-ed25519 AAAAC3Nz... phone" ];
            description = ''
                Public keys allowed to log in as sys.user. Generate one per
                client device; do not reuse the GitHub key, whose private half
                lives on this host. While empty, password auth stays on.
            '';
        };

        config = let
            hasKeys = config.sys.ssh.authorizedKeys != [];
        in {
            services.openssh = {
                enable = true;
                settings = {
                    PasswordAuthentication       = !hasKeys;
                    KbdInteractiveAuthentication = !hasKeys;
                    PermitRootLogin              = "no";
                };
            };

            users.users.${config.sys.user}.openssh.authorizedKeys.keys =
                config.sys.ssh.authorizedKeys;
        };
    };

    flake.modules.nixos.syncthing = { ... }: {
        services.syncthing.enable = true;
        services.syncthing.openDefaultPorts = true;
        networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}
