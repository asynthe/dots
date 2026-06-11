{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.xenia;
in {
    options.sys.modules.xenia = {
        enable = lib.mkEnableOption "Xenia";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            xenia-canary
        ];
    };
}
