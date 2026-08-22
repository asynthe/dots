# The shell environment that makes a machine feel like this machine. Every host
# gets it; it is the one package list that is not feature-scoped -- so anything
# in here has to be defensible on a headless box too. Tools that belong to a
# subsystem live with that subsystem instead (bluetooth, boot, network, audio).
{ ... }:
{
    flake.modules.nixos.cli = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bat
            bc
            exiftool
            eza
            fd ripgrep
            ffmpeg-full ffmpegthumbnailer
            file
            fzf skim
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
            pv
            rsync
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
