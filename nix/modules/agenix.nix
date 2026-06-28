{ config, ... }:
let
    impermanenceCfg = config.sys.disk.impermanence;
in {
    config = {
        environment.persistence.${impermanenceCfg.folder} = {
            files = [
                # agenix
                # TODO Set a proper secret management
                #"/etc/ssh/ssh_host_ed25519_key"
                #"/etc/ssh/ssh_host_ed25519_key.pub"
                #"/etc/ssh/ssh_host_rsa_key"
                #"/etc/ssh/ssh_host_rsa_key.pub"
            ];
        };
    };
}
