{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.monero;
in {
    options.sys.modules.monero = {
        enable = lib.mkEnableOption "Monero";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            monero-cli
            monero-gui
        ];
    };
}
