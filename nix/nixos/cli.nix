# The shell environment that makes a machine feel like this machine. Every host
# gets it; it is the one package list that is not feature-scoped.
{ ... }:
{
    flake.modules.nixos.cli = { pkgs, ... }: {
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
        ];
    };
}
