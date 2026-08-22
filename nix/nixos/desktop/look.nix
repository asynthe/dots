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
            fontDir.enable = true;

            fontconfig = {
                enable = true;

                # The whole font policy of this machine lives here. Every app
                # config in ~/dots asks for a *role* -- `monospace`, `sans-serif`
                # -- rather than naming a family, so changing the system font is
                # editing this attrset and nothing else. The two exceptions are
                # the terminals (TX-02, see below) and Firefox, which cannot
                # read fontconfig generics for its own default-font prefs.
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

                # TX-02 is a paid Berkeley Graphics licence, installed by hand
                # into ~/.local/share/fonts from other/font/TX-02.zip. It is
                # deliberately *not* a package here -- /home is its own btrfs
                # subvolume, so impermanence leaves it alone.
                #
                # That leaves two gaps, and one rule closes both. TX-02 ships
                # the 8 core Powerline glyphs (U+E0A0-E0A3, U+E0B0-E0B3) and
                # nothing else from Nerd Fonts -- Devicons, Font Awesome,
                # Codicons and Material are all empty -- and a host that never
                # had the zip unpacked has no TX-02 to match at all. Putting
                # JetBrainsMono NF immediately *behind* TX-02 handles both:
                # Powerline still renders in TX-02's own cut, every other icon
                # falls through to JetBrainsMono, and a fresh host degrades to
                # JetBrainsMono rather than all the way to DejaVu Sans.
                #
                # Note the hyphen: fontconfig parses a bare `TX-02` pattern as
                # family `TX` at size 2. Inside <family> tags that does not
                # apply, but in a pattern string it must be written `TX\-02`.
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

    flake.modules.nixos.theme = { pkgs, ... }: {
        # Named explicitly rather than leaning on whatever drags it in: it is the
        # only icon theme on the box, and gtk-icon-theme-name in config/gtk-*
        # points at it. Qt apps reach it via the gtk3 platform theme.
        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
        ];

        environment.sessionVariables = {
            GTK_THEME = "adw-gtk3-dark";
            # Must live here, not only in hyprland.lua's `env`: anything started
            # through `uwsm app` inherits the systemd user environment instead of
            # Hyprland's. Without a platform theme Qt6 has no icon theme name, and
            # every themed tray/menu icon silently resolves to nothing. qgtk3 also
            # derives Qt's palette from GTK_THEME, which is why there is no
            # QT_STYLE_OVERRIDE -- it named adwaita-qt, which is not installed.
            QT_QPA_PLATFORMTHEME = "gtk3";
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
