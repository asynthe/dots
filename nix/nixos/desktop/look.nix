/*
*/
{ ... }:
{
    flake.modules.nixos.fonts = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            font-manager
            fontpreview
            gnome-font-viewer
            gucharmap
        ];

        fonts = {
            fontDir.enable = true;

            fontconfig = {
                enable = true;

                defaultFonts = {
                    monospace = [
                        "JetBrainsMono Nerd Font"
                        "IosevkaTerm Nerd Font"
                        "Noto Sans Mono CJK JP"
                        "Noto Color Emoji"
                    ];
                    sansSerif = [
                        "Noto Sans"
                        "Noto Sans CJK JP"
                        "Noto Color Emoji"
                    ];
                    serif = [
                        "Noto Serif"
                        "Noto Serif CJK JP"
                        "Noto Color Emoji"
                    ];
                    emoji = [ "Noto Color Emoji" ];
                };

                localConf = ''
                    <?xml version="1.0"?>
                    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
                    <fontconfig>
                      <alias>
                        <family>TX-02</family>
                        <prefer>
                          <family>JetBrainsMono Nerd Font</family>
                          <family>Noto Sans Mono CJK JP</family>
                          <family>Noto Color Emoji</family>
                        </prefer>
                      </alias>
                    </fontconfig>
                '';
            };

            packages = with pkgs; [
                corefonts
                dejavu_fonts
                et-book
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

    flake.modules.nixos.theme = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
        ];

        environment.sessionVariables = {
            GTK_THEME = "adw-gtk3-dark";
            QT_QPA_PLATFORMTHEME = "gtk3";
        };
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
