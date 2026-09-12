{ inputs, ... }:
{
    flake.modules.nixos.gpg = { pkgs, ... }: {
        # Changing pinentry needs a `pkill gpg-agent` to take effect.
        programs.gnupg.agent = {
            enable = true;
            pinentryPackage = pkgs.pinentry-curses;
        };
    };

    flake.modules.nixos.pass = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.pass-wayland ];
    };

    flake.modules.nixos.sops = { config, lib, pkgs, ... }: {
        imports = [ inputs.sops-nix.nixosModules.sops ];

        # Outside /home, which is not guaranteed mounted when activation unlocks passwords.
        options.sys.sops.ageKeyFile = lib.mkOption {
            type        = lib.types.str;
            default     = "/persist/secrets/age-keys.txt";
            description = ''
                Private age identity used to decrypt secrets/secrets.yaml. Must
                exist before the first activation -- nixos-anywhere puts it
                there with --extra-files.
            '';
        };

        options.sys.sops.rootPassword = lib.mkOption {
            type        = lib.types.bool;
            default     = false;
            description = ''
                Give root the same hash as sys.user so `su` works. Grants
                nothing new: sys.user is in wheel and already sudos to root.
            '';
        };

        config = {
            environment.systemPackages = [ pkgs.sops pkgs.age ];
            sops.defaultSopsFile = ../../secrets/secrets.yaml;
            sops.age.keyFile = config.sys.sops.ageKeyFile;
            sops.age.sshKeyPaths = [];   # don't fall back to the host key
            sops.gnupg.sshKeyPaths = [];

            sops.secrets.user-password = {
                key            = "users/${config.sys.user}";
                neededForUsers = true;   # decrypts into /run/secrets-for-users
            };

            users.users.${config.sys.user}.hashedPasswordFile =
                config.sops.secrets.user-password.path;

            # Reuses sys.user's hash; a missing users/root key would fail activation outright.
            users.users.root.hashedPasswordFile =
                lib.mkIf config.sys.sops.rootPassword
                    config.sops.secrets.user-password.path;
        };
    };

    flake.modules.nixos.tpm = { config, ... }: {
        security.tpm2.enable = true;
        security.tpm2.pkcs11.enable = true;
        security.tpm2.tctiEnvironment.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "tss" ];
    };
}
