{ config, lib, ... }:
let
    cfg = config.sys.modules.nh;
in {
    options.sys.modules.nh = {
        enable = lib.mkEnableOption "nh NixOS helper";
        flake  = lib.mkOption {
            type        = lib.types.str;
            description = "Path to the flake used by nh";
        };
    };

    config = lib.mkIf cfg.enable {
        sys.modules.nh.flake = lib.mkDefault "/home/${config.sys.user}/dots";
        programs.nh = {
            enable           = true;
            clean.enable     = true;
            clean.extraArgs  = "--keep-since 4d --keep 3";
            flake            = cfg.flake;
        };
    };
}
