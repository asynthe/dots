{ config, pkgs, ... }: {

    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
            waylandFrontend = true;
            addons = with pkgs; [
                fcitx5-mozc
                fcitx5-gtk
            ];
        };
    };

    environment.systemPackages = with pkgs; [
        fcitx5
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
        libsForQt5.fcitx5-with-addons
        emacsPackages.mozc
    ];

    environment.sessionVariables = {
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        DefaultIMModule = "fcitx";
        INPUT_METHOD = "fcitx";
    };
}
