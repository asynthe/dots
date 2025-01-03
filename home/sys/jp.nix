{ config, lib, pkgs, ... }:
with lib;
{
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
        jp = "${pkgs.mpv}/bin/mpv --no-resume-playback https://iptv-org.github.io/iptv/countries/jp.m3u > /dev/null 2>&1 & disown";
    };

    # If using Hyprland.
    wayland.windowManager.hyprland.settings.exec-once = mkIf config.wayland.windowManager.hyprland.enable [
        "fcitx5 -d &"
    ];

    # Very helpful.
    # https://github.com/foo-dogsquared/nixos-config/blob/master/modules/home-manager/_private/suites/i18n.nix
    i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = builtins.attrValues {
            inherit (pkgs)
                fcitx5-configtool
                fcitx5-gtk # Support for GTK-based programs.
                fcitx5-lua # Lua support.
                fcitx5-mozc # Japanese input.
                #fcitx5-rime # Chinese input.
                fcitx5-table-extra
                fcitx5-table-other
            ;
            inherit (pkgs.libsForQt5) fcitx5-qt; # Supprort for QT-based programs.
        };
    };

    # Should be added by the i18n modules, this is just to make sure.
    systemd.user.sessionVariables = {
        #GTK_IM_MODULE = "wayland;fcitx"; # Wayland module ?
        GTK_IM_MODULE = "wayland"; # ?
        QT_IM_MODULE = "wayland;fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "ibus";
    };

    home.packages = builtins.attrValues {
        inherit (pkgs)
            # Apps / Video Player
            #anki-bin
            memento

            # Fonts
            ipafont
            kochi-substitute
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-emoji
            noto-fonts-extra
            sarasa-gothic
        ;
    };
}
