{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.controller;
    bluetoothCfg = config.sys.modules.bluetooth;
in {
    options.sys.modules.controller = {
        enable = lib.mkEnableOption "PS5 Controller";
    };

    config = lib.mkIf cfg.enable {

        hardware.xpadneo.enable = true;
        users.extraGroups.input.members = [ config.sys.user ];
        environment.systemPackages = with pkgs; [
            dualsensectl
        ];

        # TODO Fix
        #boot.kernelModules = [ "hid-sony" "hid-playstation" ]; (?)
        hardware.bluetooth = lib.mkIf bluetoothCfg.enable {
            powerOnBoot = true;
        };
    };
}
