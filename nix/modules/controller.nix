{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.controller;
    bluetoothCfg = config.sys.modules.bluetooth;
in {
    options.sys.modules.controller = {
        enable = lib.mkEnableOption "PS5 Controller";
    };

    config = lib.mkIf cfg.enable {

        # TODO Testing
        users.extraGroups.input.members = [ "meow" ];
        boot.kernelModules = [ "hid-sony" "hid-playstation" ];

        hardware.bluetooth.powerOnBoot = true;
        hardware.xpadneo.enable = true;
        environment.systemPackages = with pkgs; [
            dualsensectl
        ];

        hardware.bluetooth.settings.General = lib.mkIf bluetoothCfg.enable {
            Enable = "Source,Sink,Media,Socket";
            AutoEnable = true;
            ControllerMode = "bredr";
            Experimental = true;
        };
    };
}
