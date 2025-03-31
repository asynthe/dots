{ inputs, pkgs, pkgs-stable, ... }: {

    # ------------------------- Packages -------------------------
    environment.systemPackages = with pkgs; [

        # GUI
        mpv # TODO Add plugins: mpris, thumbnail, thumbfast, visualizer

        # NON HYPR
        zathura
        sioyek

        # Tools
        bat
        eza
        nh
        starship
        zoxide

        # Apps
        mpd ncmpcpp
        neovim
        superfile
        tmux tmuxp
        weechat
        yazi
        zellij

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
        alsa-utils
        cmus # Music player
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

        # Tools - Nix
        #nixfmt
        #nixops_unstable #nixops
        alejandra
        colmena
        deploy-rs
        direnv
        nix-direnv

        # --------------- Hyprland ---------------
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

        # ------------------------- Packages that don't work for now -------------------------
        #tectonic
        pkgs-stable.tectonic # LaTeX Engine
    ];
}
