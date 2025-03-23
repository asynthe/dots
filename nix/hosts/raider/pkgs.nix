{ inputs, pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # Packages from inputs
        #inputs.ghostty.packages.${system}.default
        ghostty
        superfile

        # Packages
        alacritty
        bat
        cava # TODO TEST
        cli-visualizer
        direnv
        eza
        gromit-mpx
        kitty
        mako
        mpd
        mpv # TODO Add plugins: mpris, thumbnail, thumbfast, visualizer
        ncmpcpp
        neovim
        nh
        nix-direnv
        nushell
        rofi-wayland
        sioyek
        starship
        tectonic
        tmux
        tmuxp
        waybar
        zellij

        # Librewolf
        #librewolf
        dejsonlz4 # Decompress bookmarks backup files.

        # Emacs
        emacs-pgtk
        hunspell
        hunspellDicts.en_US # English (United States) from Wordlist
        hunspellDicts.es_CL # Spanish (Chile) from rla ?

        # Emacs - Packages
        #emacsPackages.doom-modeline
        #emacsPackages.doom-modeline-now-playing # Requires playerctl.

        # TODO X11 # MOVE TO ITS OWN FILE? As it needs some specific options
        #xmonad
        #xmonad-with-packages
        #xmobar
        #dmenu
        #nitrogen
        #nsxiv
        #xclip
        #xorg.xinit
        #xorg.xprop
        #picom-jonaburg

        pkgs-stable.mapscii
    ];
}
