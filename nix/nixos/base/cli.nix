{ ... }:
{
    flake.modules.nixos.cli = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bat
            bc
            chafa
            exiftool
            eza
            fd ripgrep
            ffmpeg-full ffmpegthumbnailer
            file
            fzf skim
            ghostty.terminfo
            htop btop
            hyperfine
            imagemagickBig
            inxi
            jq
            killall
            libqalculate
            lsof
            mediainfo
            ncdu
            neomutt
            nh
            ntfs3g
            pciutils
            poppler-utils
            pv
            rsync
            smartmontools
            sox
            starship
            superfile
            tmux tmuxp zellij
            tree
            unzip unar rar
            vim helix
            wget curl
            yazi lf
            yt-dlp
            zoxide

            cachix
            direnv nix-direnv
            python3

            asciiquarium-transparent
            fastfetch pfetch-rs
            figlet lolcat
            pipes-rs
            starfetch
            tty-clock peaclock tenki clock-rs
            unimatrix
        ];
    };
}
