{ inputs, pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # --------------- Testing ---------------
        bcachefs-tools
        fbterm # -> Set 'video' user group
        fbcat
	    #ciscoPacketTracer8
	    #gns3-gui gns3-server

        # ------------------------- CLI -------------------------
        # Apps
        mpd ncmpcpp
        superfile
        weechat
        yazi
        zellij
        weechat

        # Audio visualizer and others
	    pulsemixer # from pulseaudio
        alsa-utils
        cava
        cli-visualizer
        cmus # Music player

        # Tools
	    ffmpegthumbnailer
	    file
	    hyperfine
	    imagemagickBig
	    img2pdf
	    poppler
        bat
        exiftool
        eza
        ffmpeg
        mediainfo
        nh
        pkgs-stable.tectonic #tectonic # LaTeX Engine
        sioyek
        sox
        speedtest-cli
        starship
        zoxide
        #meshlab #f3d #fstl # 3D files
        #tesseract #easyocr # OCR

        # Tools - Nix and DevOps
        #nixfmt
        #nixops_unstable #nixops
        alejandra
        colmena
        deploy-rs
        direnv
        nix-direnv
        pulumi
        opentofu #terraform
        ansible

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

        # Fetch
        pfetch
        fastfetch
        neofetch
        starfetch

        # Other
        pkgs-stable.mapscii #mapscii
    ];
}
