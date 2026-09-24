{ inputs, ... }:
{
    flake.modules.nixos.gpg = { pkgs, ... }: {
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
                Give root the same hash as the first admin in auth.nix so `su`
                works. Grants nothing new: that account is in wheel and already
                sudos to root.
            '';
        };

        config = {
            environment.systemPackages = [ pkgs.sops pkgs.age ];
            sops.defaultSopsFile = ../../../secrets/secrets.yaml;
            sops.age.keyFile = config.sys.sops.ageKeyFile;
            sops.age.sshKeyPaths = [];
            sops.gnupg.sshKeyPaths = [];

            users.users.root.hashedPasswordFile =
                lib.mkIf config.sys.sops.rootPassword
                    config.sops.secrets."password-${lib.head config.sys.admins}".path;
        };
    };

    flake.modules.nixos.tpm = { config, lib, ... }: {
        security.tpm2.enable = true;
        security.tpm2.pkcs11.enable = true;
        security.tpm2.tctiEnvironment.enable = true;
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "tss" ]; });
    };
}
