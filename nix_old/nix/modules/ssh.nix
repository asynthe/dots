{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.ssh;
    # Passwords stay enabled until a key can actually get in, so adding the
    # first key is what locks the door -- never a rebuild that locks you out.
    hasKeys = cfg.authorizedKeys != [];
in {
    options.sys.modules.ssh = {
        enable = lib.mkEnableOption "SSH";
        authorizedKeys = lib.mkOption {
            type    = lib.types.listOf lib.types.str;
            default = [];
            example = [ "ssh-ed25519 AAAAC3Nz... phone" ];
            description = ''
                Public keys allowed to log in as sys.user. Generate one per
                client device; do not reuse the GitHub key, whose private half
                lives on this host. While empty, password auth stays on.
            '';
        };
    };

    config = lib.mkIf cfg.enable {
        services.openssh = {
            enable = true;
            settings = {
                PasswordAuthentication         = !hasKeys;
                KbdInteractiveAuthentication   = !hasKeys;
                PermitRootLogin                = "no";
            };
        };

        users.users.${config.sys.user}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
}
