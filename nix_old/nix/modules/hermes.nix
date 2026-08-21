{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.ai.hermes;
in {
    options.sys.modules.ai.hermes = {
        enable = lib.mkEnableOption "Hermes";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ ];
    };
}
