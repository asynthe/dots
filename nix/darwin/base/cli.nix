{ ... }:
{
    # Same list as nix/nixos/base/cli.nix, minus what doesn't apply here:
    # ntfs3g/pciutils/inxi/ghostty.terminfo (Linux hardware & Wayland-terminal
    # specific), imagemagick (already in the neovim aspect) and rsync (already
    # in core, with its own comment on why).
    flake.modules.darwin.cli = { pkgs, ... }: {
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
            htop btop
            hyperfine
            jq
            libqalculate
            mediainfo
            ncdu
            neomutt
            poppler-utils
            pv
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
            peaclock tenki clock-rs # tty-clock is marked broken on aarch64-darwin
            unimatrix
        ];
    };

    flake.modules.darwin.atuin = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.atuin ];
    };
}
