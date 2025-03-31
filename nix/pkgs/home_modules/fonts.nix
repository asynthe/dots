{ pkgs, ... }: {

    # Left here just in case.
    # Note: if not working, try doing a `fc-cache -f`
    #fonts.fontconfig = {
        #enable = true;
        #defaultFonts = {
            #serif = [ "DejaVu Serif" "IPAGothic" ];
            #sansSerif = [ "DejaVu Sans" "IPAPGothic" ];
            #monospace = [ "JetBrainsMono Nerd Font Mono" ];
            #emoji = [ "Noto Color Emoji" ];
        #};
    #};

    home.packages = builtins.attrValues {
        inherit (pkgs)
            corefonts
            etBook # https://edwardtufte.github.io/et-book/
            font-awesome
            #nerdfonts
            office-code-pro
            source-sans-pro

            # JP
            ipafont
            kochi-substitute
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-emoji
            noto-fonts-extra
            sarasa-gothic

            #(nerdfonts.override { fonts = [  # DELETE -> HOME
              #"FiraCode"
              #"FiraMono"
              #"Iosevka"
              #"IosevkaTerm"
              #"JetBrainsMono"
              #"Meslo"
            #]; })
        ;
    };
}
