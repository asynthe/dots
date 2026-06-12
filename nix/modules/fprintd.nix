{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.fprintd;
    impermanenceCfg = config.sys.modules.impermanence;
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

        # TODO Set this variable in impermanence device (`/persist`)
        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/fprint" ];
    };
}
