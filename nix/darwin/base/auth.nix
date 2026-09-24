{ ... }:
let
    people = import ../../../auth.nix;
in {
    # Same auth.nix as NixOS reads, same field (`keys`) -- everything else
    # there (admin, passwordKey, groups) is for creating an account, which
    # nix-darwin does not do. This aspect only authorizes sys.user's keys for
    # sshd and turns on Remote Login; it never creates or touches accounts.
    flake.modules.darwin.auth = { config, lib, ... }: {
        config = {
            assertions = [{
                assertion = people ? ${config.sys.user};
                message = "sys.user is \"${config.sys.user}\", which auth.nix does not declare.";
            }];

            services.openssh.enable = true;

            system.activationScripts.postActivation.text = let
                keys = people.${config.sys.user}.keys or [ ];
                sshDir = "/Users/${config.sys.user}/.ssh";
            in ''
                mkdir -p ${sshDir}
                chmod 700 ${sshDir}
                cat > ${sshDir}/authorized_keys <<'KEYS'
                ${lib.concatStringsSep "\n" keys}
                KEYS
                chmod 600 ${sshDir}/authorized_keys
                chown -R ${config.sys.user}:staff ${sshDir}
            '';
        };
    };
}
