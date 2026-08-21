{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.sys.secrets;
    has = name: builtins.elem name cfg;
in {
    options.sys.secrets = lib.mkOption {
        type        = lib.types.listOf (lib.types.enum [ "pass" "gpg" "sops" ]);
        default     = [];
        description = "Secrets management tooling to enable (pass, gpg, sops)";
    };

    config = lib.mkMerge [
        (lib.mkIf (has "gpg") {
            # If gpg-agent is already running under a different pinentry:
            # `pkill gpg-agent` then let it respawn via the socket
            programs.gnupg.agent = {
                enable = true;
                pinentryPackage = pkgs.pinentry-curses;
            };
        })

        (lib.mkIf (has "pass") {
            environment.systemPackages = [ pkgs.pass-wayland ];
        })

        (lib.mkIf (has "sops") {
            environment.systemPackages = [ pkgs.sops pkgs.age ];
            sops.defaultSopsFile = ../../secrets/secrets.yaml;
            # Root-owned and outside /home: activation unlocks user passwords
            # before /home is guaranteed mounted. Same age identity as
            # ~/.config/sops/age/keys.txt, just readable this early.
            sops.age.keyFile = "/persist/secrets/age-keys.txt";
            sops.age.sshKeyPaths = [];   # don't fall back to the host key
            sops.gnupg.sshKeyPaths = [];

            sops.secrets.user-password = {
                neededForUsers = true;   # decrypts into /run/secrets-for-users
            };
        })

    ];
}
