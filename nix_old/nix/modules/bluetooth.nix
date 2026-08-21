{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.bluetooth;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.bluetooth = {
        enable = lib.mkEnableOption "Bluetooth";
    };

    config = lib.mkIf cfg.enable {
        services.blueman.enable = true;
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/bluetooth" ];

        # TODO hardware.bluetooth.settings to disable hands-free mode, test with the nothing earphones
    };
}
