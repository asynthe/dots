{ pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # ───────────────────────── Emacs ─────────────────────────
        #emacs-pgtk
        #hunspell
        #hunspellDicts.en_US # English (United States) from Wordlist
        #hunspellDicts.es_CL # Spanish (Chile) from rla ?

        # Emacs - Packages
        #emacsPackages.doom-modeline
        #emacsPackages.doom-modeline-now-playing # Requires playerctl.

        # ───────────────────────── Thumbnails (PCmanFM) ─────────────────────────
        #pcmanfm
        #nufraw-thumbnailer # .raw files (raw-thumbnailer)
        #evince # Adobe .pdf files
        #ffmpegthumbnailer # Video files
        #freetype # Font files
        #libgsf # .odf files

        #with pkgs.libsForQt5; [ dolphin ];
        #with pkgs.xfce; [ thunar tumbler ];

        # ───────────────────────── CLI ─────────────────────────
        # Apps
        mpd ncmpcpp
        superfile
        weechat
        yazi
        zellij

        # Audio visualizer and others
        alsa-utils pulsemixer # from pulseaudio
        cava
        cmus # Music player
        easyeffects
        pulseaudioFull

        # Tools
	    img2pdf
	    poppler
        keepassxc
        networkmanagerapplet
        #meshlab #f3d #fstl # 3D files
        #tesseract #easyocr # OCR

        # Fun
	    figlet lolcat dotacat
        #nhentai # ( ͡° ͜ʖ ͡°) 
	    peaclock tty-clock
	    unimatrix
        asciiquarium-transparent
        bottom
        btop
        cpu-x
        pipes-rs
        #pkgs-stable.mapscii #mapscii

        # Fetch
        pfetch
        fastfetch
        starfetch

        # ───────────────────────── GUI ─────────────────────────
        # Social
        signal-desktop
        telegram-desktop
        discord #webcord # fuck discord
        #hexchat # IRC

        # Propietary
	    #ciscoPacketTracer8
	    #gns3-gui gns3-server
        #whatsapp-for-linux # Whatsapp 😂😍🫢 ❗
        #microsoft-edge # Just for the PDF editor
        spotify
        zoom-us
        #davinci-resolve # Not working

        # Terms
	    kitty
        alacritty
        cool-retro-term
        ghostty
        wezterm

        # Apps
        gimp3-with-plugins # Remember to configure photogimp
        librewolf dejsonlz4 # Decompress bookmarks backup files.
        ungoogled-chromium #brave
        tor-browser
        mpv hypnotix
        qbittorrent
        qmmp
        sioyek zathura
        wayfire
        wf-recorder
        #aegisub
        #etcher
        #gparted
        #keepassxc
        #libreoffice
        #obsidian
        #ventoy-full #ventoy
        #kdenlive
        #nicotine-plus

        # Japanese
        anki-bin
        memento
        pkgs-stable.mokuro

        # Astronomy
	    #celestia
	    #libnova
	    #stellarium
    ];
}
