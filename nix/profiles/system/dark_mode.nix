{ config, pkgs, lib, ... }:
with lib; with types;
let
  cfg = config.meta.system;
in {
    options.meta.system = {
        dark-mode = mkEnableOption "Enable dark mode for both GTK and QT apps.";
    };

    config = mkIf cfg.dark-mode {

        environment.sessionVariables = {
            GDK_THEME = "Adwaita-dark";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            QT_STYLE_OVERRIDE = "adwaita-dark";
        };

        qt = {
            enable = true;
            platformTheme = "qt5ct";
            style = "adwaita-dark";
        };

        programs.dconf = {
            enable = true;
            #settings."org/gnome/desktop/interface".color-sheme = "prefer-dark";
            #settings."org/gnome/desktop/background".picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
        };

        # Packages
        environment.systemPackages = with pkgs; [
            adwaita-qt
            adwaita-qt6
            adwaita-icon-theme
            gnome-themes-extra
            gsettings-desktop-schemas
            libsForQt5.qt5.qttools
        ];
    };
}
