{ lib, pkgs, ... }: {

    # NOTE
    # There seems to be something weird with GTK apps
    # It seems that what enabled the dark theme was in 
    # the libvirt configuration file.

    # REMOVE for a proper dots mkOutOfStoreSymlink?
    # Overrides - Hyprland (Border Color)
    #wayland.windowManager.hyprland.settings.general = {
        #"col.active_border" = lib.mkForce "rgb(451F67)"; # Purple
        #"col.active_border" = lib.mkForce "rgb(ff0000)"; # Xmonad Red
        #"col.inactive_border" = lib.mkForce "rgb(000000)"; # Black
    #};
    #programs.alacritty.settings.colors.primary.background = lib.mkForce "0x000000";

    stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";
        image = ./img/grey.png;

        # -------------- Specific targets --------------
        targets = {
            #nixvim.transparentBackground.main = true;
            #nixvim.transparent_bg.sign_column = true;
            #wezterm.enable = false;
            yazi.enable = false;
        };

        # -------------- Colorscheme --------------
        # https://tinted-theming.github.io/base16-gallery/
        # or `nix build nixpkgs#base16-schemes`

        # Colorschemes
        #base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
        #base16Scheme = "${pkgs.base16-schemes}/share/themes/icy.yaml";
        #base16Scheme = "${pkgs.base16-schemes}/share/themes/synth-midnight-dark.yaml";

        # default-dark
        #base16Scheme = {
            #base00 = "181818";
            #base00 = "000000"; # This replaces base00 with dark/transparent
            #base01 = "282828";
            #base02 = "383838";
            #base03 = "585858";
            #base04 = "b8b8b8";
            #base05 = "d8d8d8";
            #base06 = "e8e8e8";
            #base07 = "f8f8f8";
            #base08 = "ab4642";
            #base09 = "dc9656";
            #base0A = "f7ca88";
            #base0B = "a1b56c";
            #base0C = "86c1b9";
            #base0D = "7cafc2";
            #base0E = "ba8baf";
            #base0F = "a16946";
        #};

        # synth-midnight-dark
        base16Scheme = {
            #base00 = "050608";
            base00 = "000000"; # This replaces base00 with dark/transparent
            base01 = "1a1b1c";
            base02 = "28292a";
            base03 = "474849";
            base04 = "a3a5a6";
            base05 = "c1c3c4";
            base06 = "cfd1d2";
            base07 = "dddfe0";
            base08 = "b53b50";
            base09 = "ea770d";
            base0A = "c9d364";
            base0B = "06ea61";
            base0C = "42fff9";
            base0D = "03aeff";
            base0E = "ea5ce2";
            base0F = "cd6320";
        };

        # -------------- Opacity --------------
        #opacity.applications = 1.0;
        opacity.terminal = 0.8;
        #opacity.desktop = 1.0;
        #opacity.popups = 1.0;

        # -------------- Cursor --------------
        cursor.package = pkgs.capitaine-cursors;
        cursor.name = "capitaine-cursors-white";
        cursor.size = 18; # default `32`.

        # -------------- Fonts --------------
        fonts = {

            # Size
            sizes.desktop = 6; # default `10`.
            sizes.popups = 10; # default `10`.
            sizes.terminal = 14; # default `12`.

            # Monospace for everything.
            #serif = config.stylix.fonts.monospace;
            #sansSerif = config.stylix.fonts.monospace;
            #emoji = config.stylix.fonts.monospace;
            
            # ???
            #packages = builtins.attrValues {
                #inherit (pkgs)
                    #dejavu_fonts
                    #etBook # https://edwardtufte.github.io/et-book/
                    #font-awesome
                    #nerdfonts
                    #noto-fonts-emoji
                    #office-code-pro
                    #source-sans-pro
                #;
            #};

            # Alacritty wasn't able to find JetBrainsMono
            # until I ran `fc-cache -fv`.
            serif.name = "DejaVu Serif";
            serif.package = pkgs.dejavu_fonts;
            sansSerif.name = "DejaVu Sans";
            sansSerif.package = pkgs.dejavu_fonts;
            monospace.name = "JetBrainsMono Nerd Font";
            monospace.package = pkgs.nerd-fonts.jetbrains-mono;
            emoji.name = "Noto Color Emoji";
            emoji.package = pkgs.noto-fonts-emoji;
        };
    };

    # -------------------------------------------------
    # Theme

    dconf.enable = true;
    #home = {
        #pointerCursor = {
            #gtk.enable = true;
            #package = pkgs.capitaine-cursors;
            #name = "capitaine-cursors-white";
            #size = 24;
            #x11.defaultCursor = "capitaine-cursors-white";
        #};
    #};

    #gtk = {
        #enable = true;
        #theme = {
	        #name = "Adwaita-dark";
            #package = pkgs.adwaita-qt;

            #name = "Materia-dark";
            #package = pkgs.materia-theme;
        #};
    #};

    qt = {
        enable = true;
	    #platformTheme = "adwaita";
        #style.name = "adwaita-dark";
        #style.package = pkgs.adwaita-qt;
    };
}
