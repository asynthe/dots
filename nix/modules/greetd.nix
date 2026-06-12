/*
TODO Enable if one or more desktop env / tiling wm is enabled
In this case Hyprland `sys.modules.hyprland`
*/
{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.greetd;
in {
    options.sys.modules.greetd = {
        enable = lib.mkEnableOption "greetd";
    };

    config = lib.mkIf cfg.enable {
        services.greetd = {
            enable = true;
            useTextGreeter = true; # When using `tuigreet`
            settings.default_session.command = lib.concatStringsSep " " [
                "${pkgs.tuigreet}/bin/tuigreet"
                "--remember"
                "--asterisks"

                # TODO Test
                #"--width"
                #"40"
                #"--time"
                #"--theme"
                #"'border=magenta;prompt=yellow;time=cyan;container=black;input=green'"

                # TODO mkif meta.system.hyprland.enable
                "--cmd"
                "'uwsm start hyprland-uwsm.desktop'"
            ];
        };
    };
}
