{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.atuin;
in {
    options.sys.modules.atuin = {
        enable = lib.mkEnableOption "Atuin";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ atuin ];
    };
}
