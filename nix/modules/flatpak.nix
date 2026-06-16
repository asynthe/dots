{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.flatpak;
    impermanenceCfg = config.sys.modules.impermanence;
in {
    options.sys.modules.flatpak = {
        enable = lib.mkEnableOption "Flatpak";
    };

    config = lib.mkIf cfg.enable {
        services.flatpak.enable = true;

        # TODO set this variable in impermanence device (`/persist`)
        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/flatpak" ];
    };
}
