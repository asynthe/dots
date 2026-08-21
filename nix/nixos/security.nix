{ inputs, ... }:
{
    flake.modules.nixos.gpg = { pkgs, ... }: {
        # If gpg-agent is already running under a different pinentry:
        # `pkill gpg-agent` then let it respawn via the socket
        programs.gnupg.agent = {
            enable = true;
            pinentryPackage = pkgs.pinentry-curses;
        };
    };

    flake.modules.nixos.pass = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.pass-wayland ];
    };

    flake.modules.nixos.sops = { config, pkgs, ... }: {
        imports = [ inputs.sops-nix.nixosModules.sops ];

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

        users.users.${config.sys.user}.hashedPasswordFile =
            config.sops.secrets.user-password.path;
    };

    flake.modules.nixos.tpm = { config, ... }: {
        security.tpm2.enable = true;
        security.tpm2.pkcs11.enable = true;
        security.tpm2.tctiEnvironment.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "tss" ];
    };
}
