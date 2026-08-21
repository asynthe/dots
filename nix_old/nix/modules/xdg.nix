{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.xdg;
in {
    options.sys.modules.xdg = {
        enable = lib.mkEnableOption "XDG";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            xdg-ninja
        ];

        # TODO Set XDG base dirs + per-app redirects (gnupg, android, wine, npm, gradle, expo)
    };
}
