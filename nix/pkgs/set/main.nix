{ inputs, pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # ------------------------- CLI -------------------------
        # Apps
        mpd ncmpcpp
        superfile
        weechat
        yazi
        zellij

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
	    unar
        #meshlab #f3d #fstl # 3D files
        exiftool
        ffmpeg
        mediainfo
        speedtest-cli
        #tesseract #easyocr # OCR
        sox
        bat
        eza
        nh
        starship
        zoxide
        pkgs-stable.tectonic #tectonic # LaTeX Engine

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
