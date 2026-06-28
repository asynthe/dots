{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.fwupd;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.fwupd = {
        enable = lib.mkEnableOption "fwupd";
    };

    config = lib.mkIf cfg.enable {
        services.fwupd.enable = true;

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/fwupd" ];
    };
}
