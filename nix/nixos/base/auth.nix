{ lib, ... }:
let
    defaults = {
        admin       = false;
        passwordKey = null;
        groups      = [];
        keys        = [];
    };

    people = lib.mapAttrs
        (_: person: defaults // person)
        (import ../../../auth.nix);

    admins = lib.attrNames (lib.filterAttrs (_: person: person.admin) people);
in {
    flake.modules.nixos.auth = { config, lib, pkgs, ... }: {
        options.sys.admins = lib.mkOption {
            type        = lib.types.listOf lib.types.str;
            readOnly    = true;
            default     = admins;
            description = "Accounts in wheel, from auth.nix. Aspects add their groups to these.";
        };

        config = {
            assertions = lib.mapAttrsToList (name: person: {
                assertion = person.admin -> person.passwordKey != null;
                message = "auth.nix: ${name} is an admin and needs a passwordKey."
                    + " wheel requires a password, so a locked account can never sudo.";
            }) people ++ [
                {
                    assertion = people ? ${config.sys.user};
                    message = "sys.user is \"${config.sys.user}\", which auth.nix does not declare."
                        + " The seat has to be a real account: it autologins.";
                }
            ];

            users.users = lib.mapAttrs (name: person: {
                isNormalUser = true;
                shell        = pkgs.zsh;
                extraGroups  = person.groups ++ lib.optional person.admin "wheel";

                openssh.authorizedKeys.keys = person.keys;

                hashedPasswordFile = lib.mkIf (person.passwordKey != null)
                    config.sops.secrets."password-${name}".path;
                hashedPassword = lib.mkIf (person.passwordKey == null) "!";
            }) people;

            sops.secrets = lib.mapAttrs' (name: person:
                lib.nameValuePair "password-${name}" {
                    key            = person.passwordKey;
                    neededForUsers = true;
                }
            ) (lib.filterAttrs (_: person: person.passwordKey != null) people);

            nix.settings.trusted-users = admins;
        };
    };
}
