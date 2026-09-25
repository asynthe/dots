{ ... }:
let
    people = import ../../../auth.nix;
in {
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
