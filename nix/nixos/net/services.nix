{ ... }:
{
    flake.modules.nixos.ssh = { config, lib, ... }: {
        # Adding the first key is what locks the door, never a rebuild.
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

        # Additive: sys.user is always in the list, so no edit here can lock it out.
        options.sys.ssh.extraUsers = lib.mkOption {
            type    = lib.types.listOf lib.types.str;
            default = [];
            example = [ "sarten" ];
            description = ''
                Further accounts the keys above may log in as, alongside
                sys.user. Listing a name here does not create the account.
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

            users.users = lib.genAttrs
                ([ config.sys.user ] ++ config.sys.ssh.extraUsers)
                (_: { openssh.authorizedKeys.keys = config.sys.ssh.authorizedKeys; });
        };
    };

    flake.modules.nixos.syncthing = { ... }: {
        services.syncthing.enable = true;
        services.syncthing.openDefaultPorts = true;
        networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}
