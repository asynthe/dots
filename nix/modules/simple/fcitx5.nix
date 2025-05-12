{ config, lib, pkgs, ... }:
with lib;
{
    # ───────────────────────── Environment Variables ─────────────────────────
    environment.sessionVariables = {
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        DefaultIMModule = "fcitx";
        INPUT_METHOD = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "ibus";
    };

    # ───────────────────────── Fcitx5 + mozc ─────────────────────────
    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
            waylandFrontend = true;
            addons = with pkgs; [
                fcitx5-gtk # Support for GTK-based programs
                fcitx5-mozc # Japanese input
            ];
        };
    };

    # ───────────────────────── Packages ─────────────────────────
    environment.systemPackages = with pkgs; [
        fcitx5
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
        libsForQt5.fcitx5-with-addons
        emacsPackages.mozc

        # Apps / Video Player
        anki-bin
        memento
    ];

    # ───────────────────────── Fonts ─────────────────────────
    fonts.packages = with pkgs; [
        ipafont
        kochi-substitute
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        noto-fonts-extra
        sarasa-gothic
    ];
}
