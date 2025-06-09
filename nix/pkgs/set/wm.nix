{ pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # ───────────────────────── Emacs ─────────────────────────
        emacs-pgtk
        hunspell
        hunspellDicts.en_US # English (United States) from Wordlist
        hunspellDicts.es_CL # Spanish (Chile) from rla ?

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
        weechat

        # Audio visualizer and others
        alsa-utils pulsemixer # from pulseaudio
        cava
        cmus # Music player

        # Tools
	    img2pdf
	    poppler
        #meshlab #f3d #fstl # 3D files
        #tesseract #easyocr # OCR

        # Fun
	    figlet
	    lolcat
	    nhentai # ( ͡° ͜ʖ ͡°) 
	    peaclock tty-clock
	    unimatrix
        asciiquarium-transparent
        bottom
        btop
        cpu-x
        pipes-rs
        pkgs-stable.mapscii #mapscii

        # Fetch
        pfetch
        fastfetch
        neofetch
        starfetch

        # ───────────────────────── GUI ─────────────────────────
        # Social
        signal-desktop
        telegram-desktop
        webcord #discord # fuck discord
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
        mpv hypnotix
        gimp3-with-plugins # Remember to configure photogimp
        qmmp
        sioyek zathura
        #aegisub
        #etcher
        #gparted
        #keepassxc
        #libreoffice
        #obsidian
        #ungoogled-chromium #brave
        #ventoy-full #ventoy
        #kdenlive
        #nicotine-plus
        wayfire
        librewolf dejsonlz4 # Decompress bookmarks backup files.

        # Astronomy
	    #celestia
	    #libnova
	    #stellarium
    ];
}
