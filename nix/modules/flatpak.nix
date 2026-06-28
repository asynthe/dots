{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.flatpak;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.flatpak = {
        enable = lib.mkEnableOption "Flatpak";
    };

    config = lib.mkIf cfg.enable {
        services.flatpak.enable = true;

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/flatpak" ];
    };
}
