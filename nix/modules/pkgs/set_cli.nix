{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        acpi
        bat
        bc
        bluez-tools bluetuith
        efibootmgr
        exiftool
        eza
        fd ripgrep
        ffmpeg-full ffmpegthumbnailer
        file
        fzf skim
        htop btop
        hyperfine
        imagemagickBig
        impala
        inxi
        jq
        killall
        libqalculate
        lsof
        #macchanger
        mediainfo
        ncdu
        neomutt
        vim
        helix
        nh
        pass-wayland
        pv
        ripgrep
        sox
        starfetch
        starship
        superfile
        tmux tmuxp zellij
        tree
        unzip unar rar
        wiremix
        yazi lf
        yt-dlp
        zoxide

        # net
        ntfs3g
        rsync
        speedtest-cli
        weechat irssi
        wget curl

        # nix / dev
        cachix
        direnv nix-direnv
        python3

        # swag
        asciiquarium-transparent
        fastfetch pfetch-rs
        figlet lolcat
        pipes-rs
        tty-clock peaclock tenki clock-rs
        unimatrix

        # gui
        networkmanagerapplet
        zathura sioyek
        signal-desktop

        # music
        mpd ncmpcpp
        mixxx
        spek
        #projectm_3 # Milkdrop 3

        # Audio vis and others
        alsa-utils pulsemixer
        cava
        cmus
    ];
}
