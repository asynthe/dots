{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.ime;
in {
    options.sys.modules.ime = {
        enable = lib.mkEnableOption "Fcitx5";
    };

    config = lib.mkIf cfg.enable {
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
