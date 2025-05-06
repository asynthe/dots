{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # -------------- GUI --------------
        # Social
        signal-desktop
        telegram-desktop
        #hexchat # IRC
        webcord #discord # fuck discord
        #whatsapp-for-linux # Whatsapp 😂😍🫢 ❗

        # Propietary
        microsoft-edge # TODO Just for the PDF viewer.
        spotify
        zoom-us

        # Terms
	    kitty
        alacritty
        cool-retro-term
        ghostty
        wezterm

        # Apps
        #aegisub # Subtitle Editor
        #emacs29-pgtk
        #etcher
        #gimp-with-plugins #gimp # Remember to configure photogimp.
        #gparted
        hypnotix
        #keepassxc
        #libreoffice
        #obsidian
        #ungoogled-chromium #brave
        #ventoy-full #ventoy
        #aegisub
        #davinci-resolve # Not working.
        #kdenlive
        #nicotine-plus
        #qmmp
        #wf-recorder
        wayfire
        librewolf dejsonlz4 # Decompress bookmarks backup files.

        # Astronomy
	    #celestia
	    #libnova
	    #stellarium

        # -------------- Emacs --------------
        emacs-pgtk
        hunspell
        hunspellDicts.en_US # English (United States) from Wordlist
        hunspellDicts.es_CL # Spanish (Chile) from rla ?

        # Emacs - Packages
        #emacsPackages.doom-modeline
        #emacsPackages.doom-modeline-now-playing # Requires playerctl.

        # -------------- Thumbnailers for PCmanFM --------------
        #pcmanfm
        #nufraw-thumbnailer # .raw files (raw-thumbnailer)
        #evince # Adobe .pdf files
        #ffmpegthumbnailer # Video files
        #freetype # Font files
        #libgsf # .odf files

        #with pkgs.libsForQt5; [ dolphin ];
        #with pkgs.xfce; [ thunar tumbler ];
    ];
}
