{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.bluetooth;
    impermanenceCfg = config.sys.modules.impermanence;
in {
    options.sys.modules.bluetooth = {
        enable = lib.mkEnableOption "Bluetooth";
    };

    config = lib.mkIf cfg.enable {
        services.blueman.enable = true;
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;

        # TODO set this variable, maybe in impermanence file
        environment.persistence."/persist".directories = lib.mkIf impermanenceCfg.enable [ "/var/lib/bluetooth" ];

        #hardware.bluetooth.settings = {
        # TODO Test this with the nothing earphones
        # No hands free mode
        #settings.General = {
        #Enable = "Source,Sink,Headset,Gateway,Handsfree";
        #Disable = "Headset";
        #DiscoverableTimeout = 0;
        #FastConnectable = true;
        #};
        #settings.Policy.AutoEnable = true;
        #};
    };
}
