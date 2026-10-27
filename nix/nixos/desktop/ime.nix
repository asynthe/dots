{ ... }:
{
    flake.modules.nixos.ime = { pkgs, ... }: {
        environment.sessionVariables = {
            #GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            INPUT_METHOD = "fcitx";
            XMODIFIERS = "@im=fcitx";
            SDL_IM_MODULE = "fcitx";
            GLFW_IM_MODULE = "ibus";
            DefaultIMModule = "fcitx";
        };
        i18n.inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
                waylandFrontend = true;
                addons = with pkgs; [
                    fcitx5-gtk
                    fcitx5-mozc
                    qt6Packages.fcitx5-configtool
                ];
            };
        };
    };
}
