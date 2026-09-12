# The shell environment every host gets, so it has to be defensible headless.
# Subsystem tools live with their subsystem instead.
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
            ghostty.terminfo   # ssh from a ghostty client needs this end too
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

            # nix / dev
            cachix
            direnv nix-direnv
            python3

            # swag
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
