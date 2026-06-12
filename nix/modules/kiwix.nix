{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.kiwix;
in {
    options.sys.modules.kiwix = {
        enable = lib.mkEnableOption "Kiwix";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ kiwix ];
    };
}
