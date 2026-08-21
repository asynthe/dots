/*
# Note: if fonts are not working, try doing a `fc-cache -f`
*/
{ ... }:
{
    flake.modules.nixos.fonts = { pkgs, ... }: {
        # Previewing a family, and looking up whether a glyph actually exists
        # in one -- handy with nerd-fonts icons and CJK.
        # `font-manager` is the fuller alternative (enable/disable, compare),
        # but it drags in webkitgtk for ~170 MiB.
        environment.systemPackages = with pkgs; [
            font-manager
            fontpreview
            gnome-font-viewer
            gucharmap
        ];

        fonts = {
            fontconfig.enable = true;
            fontDir.enable = true;
            packages = with pkgs; [
                corefonts
                dejavu_fonts
                et-book # https://edwardtufte.github.io/et-book/
                font-awesome
                liberation_ttf
                office-code-pro
                source-sans-pro
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji
                nerd-fonts.fira-code
                nerd-fonts.iosevka-term
                nerd-fonts.iosevka-term-slab
                nerd-fonts.jetbrains-mono
                nerd-fonts.mononoki
                nerd-fonts.overpass
                nerd-fonts.sauce-code-pro
                nerd-fonts.ubuntu-sans
                nerd-fonts.zed-mono
            ];
        };
    };

    flake.modules.nixos.theme = { ... }: {
        environment.sessionVariables = {
            GTK_THEME = "adw-gtk3-dark";
            QT_STYLE_OVERRIDE = "adwaita-dark";
        };
    };

    flake.modules.nixos.xdg = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            xdg-ninja
        ];

        # TODO Set XDG base dirs + per-app redirects (gnupg, android, wine, npm, gradle, expo)
    };

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
