{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.qbittorrent;
in {
    options.sys.modules.qbittorrent = {
        enable = lib.mkEnableOption "Qbittorrent";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ qbittorrent ];
    };
}
