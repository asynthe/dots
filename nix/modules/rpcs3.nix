{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.rpcs3;
in {
    options.sys.modules.rpcs3 = {
        enable = lib.mkEnableOption "RPCS3";
    };
    
    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            rpcs3
        ];
    };
}
