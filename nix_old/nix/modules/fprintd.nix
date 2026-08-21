{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.fprintd;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.fprintd = {
        enable = lib.mkEnableOption "fprintd";
    };

    config = lib.mkIf cfg.enable {
        services.fprintd.enable = true;
        security.pam.services = {
            login.fprintAuth = true;
            sudo.fprintAuth = true;
        };

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/fprint" ];
    };
}
