{ pkgs, ... }: {

    # ───────────────────────── Fonts ─────────────────────────
    # Note: if not working, try doing a `fc-cache -f`
    fonts = {
        fontconfig.enable = true;
        fontDir.enable = true;
        #fontconfig.defaultFonts = {
            #serif = [ "DejaVu Serif" "IPAGothic" ];
            #sansSerif = [ "DejaVu Sans" "IPAPGothic" ];
            #monospace = [ "JetBrainsMono Nerd Font Mono" ];
            #emoji = [ "Noto Color Emoji" ];
        #};
        packages = with pkgs; [
            corefonts
            dejavu_fonts
            etBook # https://edwardtufte.github.io/et-book/
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
}
