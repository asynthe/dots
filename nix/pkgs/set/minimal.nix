{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # ───────────────────────── Minimal ─────────────────────────
	    bc
	    fd ripgrep
	    imagemagickBig
	    libqalculate
	    ncdu
        acpi
        bat
        exiftool
        eza
        ffmpeg-full ffmpegthumbnailer
        file
        fzf skim
        git bfg-repo-cleaner jujutsu
        htop btop
        hyperfine
        jq
        killall
        lsof
        mediainfo
        neovim
        nh
        pass-wayland
        pv
        rsync
        sioyek
        sox
        speedtest-cli
        starship
        tmux tmuxp
        tree
        wget curl
        yazi
        yt-dlp
        zoxide

        # GUI
        ghostty

        # Tagging
        puddletag

        # Email
        neomutt
      ];
}
