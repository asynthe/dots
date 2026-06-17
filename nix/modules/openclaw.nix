{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.openclaw;
in {
    options.sys.modules.openclaw = {
        enable = lib.mkEnableOption "OpenClaw";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ openclaw ];
    };
}
