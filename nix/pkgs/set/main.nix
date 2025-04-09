{ inputs, pkgs, pkgs-stable, ... }: {

    # ------------------------- Packages -------------------------
    environment.systemPackages = with pkgs; [

        # ------------------------- CLI -------------------------
        # Apps
        mpd ncmpcpp
        neovim
        superfile
        tmux tmuxp
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
	    fd
	    ffmpegthumbnailer
	    file
	    fzf
	    hyperfine
	    imagemagickBig
	    img2pdf
	    jq
	    libqalculate
	    poppler
	    ripgrep
	    unar
        #meshlab #f3d #fstl # 3D files
        exiftool
        ffmpeg
        git bfg-repo-cleaner
        libqalculate
        mediainfo
        pv
        ripgrep
        skim
        sox
        speedtest-cli
        #tesseract #easyocr # OCR

        # Tools
        bat
        eza
        nh
        starship
        zoxide
        pkgs-stable.tectonic #tectonic # LaTeX Engine

        # Tools - Nix
        #nixfmt
        #nixops_unstable #nixops
        alejandra
        colmena
        deploy-rs
        direnv
        nix-direnv

        # ------------------------- GUI -------------------------
        mpv # TODO Add plugins: mpris, thumbnail, thumbfast, visualizer
        sioyek #zathura # TODO: Remove `zathura` once replaced

        # ------------------------- GUI - Hyprland -------------------------
        brightnessctl
        gromit-mpx
        hyprshot
        mako
        mpvpaper
        pavucontrol
        rofi-wayland
        swappy
        waybar
        wofi
        #pkgs.libsForQt5 polkit-kde-agent
    ];
}
