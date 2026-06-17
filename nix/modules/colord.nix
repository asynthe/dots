{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.colord;
in {
    options.sys.modules.colord = {
        enable = lib.mkEnableOption "colord";
    };

    config = lib.mkIf cfg.enable {
        services.colord.enable = true;
    };
}
