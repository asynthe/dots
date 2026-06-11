{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.tectonic;
in {
    options.sys.modules.tectonic = {
        enable = lib.mkEnableOption "Tectonic";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            tectonic
        ];
    };
}
