{ pkgs, ... }: {

    # ───────────────────────── Environment Variables ─────────────────────────
    environment.sessionVariables = {
        #GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        INPUT_METHOD = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "ibus";
        DefaultIMModule = "fcitx";
    };

    # ───────────────────────── Fcitx5 + mozc ─────────────────────────
    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
            waylandFrontend = true;
            addons = with pkgs; [
                fcitx5-configtool
                fcitx5-gtk # Support for GTK-based programs
                fcitx5-mozc # Japanese input
            ];
        };
    };
}
