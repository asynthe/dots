{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.wine;
in {
    options.sys.modules.wine = {
        enable = lib.mkEnableOption "Wine";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            winetricks
            mono # .NET
            wineWow64Packages.staging
            wineWow64Packages.waylandFull
            wineWow64Packages.fonts
        ];
    };
}
