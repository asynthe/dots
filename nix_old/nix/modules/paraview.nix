{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.paraview;
in {
    options.sys.modules.paraview = {
        enable = lib.mkEnableOption "Paraview";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ paraview ];
    };
}
