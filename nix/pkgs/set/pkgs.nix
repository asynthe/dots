{ inputs, pkgs, pkgs-stable, ... }: {

    # ------------------------- Packages -------------------------
    environment.systemPackages = with pkgs; [

        # ...

        # Packages from inputs
        #inputs.ghostty.packages.${system}.default
        #inputs.swww.packages.${pkgs.system}.swww
        swww
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
        mpvpaper
        ncmpcpp
        neovim
        nh
        nix-direnv
        nushell
        rofi-wayland
        starship
        tmux
        tmuxp
        waybar
        zellij
        yazi
        wezterm
        zoxide

        # Showing off
        neofetch
        pfetch
        fastfetch
        wallust

        # Tools
        git
	    fd
	    ffmpegthumbnailer
	    file
	    fzf
	    jq
	    poppler
	    ripgrep
	    unar
        exiftool
        alsa-utils
        bfg-repo-cleaner
        zathura
        sioyek
        skim
        libqalculate

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

        # Wayland - Hyprland
        imv
        wl-clipboard
        brightnessctl
        grim slurp
        mako libnotify
        mpvpaper
        ripdrag
        swayidle
        wofi
        libsForQt5.polkit-kde-agent # Authentication agent
        libsForQt5.qt5.qtwayland

        # X11 - Xmonad
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
        #xargs
        #xlsclients

        # Other
        wayfire
        pass-wayland

        # Propietary
        microsoft-edge # Just for editing PDFs

        # Testing
        fbterm # -> Set 'video' user group
        fbcat
	    #ciscoPacketTracer8
	    #gns3-gui gns3-server
	    #slides
	    #zoom-us
	    #slack #slack-cli #slack-term # ?

        # ------------------------- Stable Packages -------------------------
        pkgs-stable.mapscii
        pkgs-stable.tectonic
    ];
}
