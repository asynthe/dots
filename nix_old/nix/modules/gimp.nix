{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.gimp;
in {
    options.sys.modules.gimp = {
        enable = lib.mkEnableOption "Gimp";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            gimp-with-plugins
        ];
    };
}
