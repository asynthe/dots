{ pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [

        # ───────────────────────── Testing ─────────────────────────
        # Testing
        fbcat
        fbterm # -> Set 'video' user group
        htop
        iotop
        lm_sensors
        pciutils
        powertop
        usbutils

        # Tools
        lsof
        tree
        pkgs-stable.tectonic #tectonic # LaTeX Engine

        # Filesystem tools
        bcachefs-tools
        gptfdisk

        # Networking
        httpie

        # NVMe / SSD Testing
		fio
		hdparm
		nvme-cli

        # Nvidia
        nvtopPackages.full #pkgs-stable.nvtopPackages.full
        #nvtopPackages.nvidia

        # ───────────────────────── CLI ─────────────────────────
	    ascii
	    bc
	    fd ripgrep
	    fzf skim
	    git bfg-repo-cleaner
	    imagemagickBig
	    libqalculate
	    ncdu
        acpi
        bat
        exiftool
        eza
        ffmpeg-full ffmpegthumbnailer
        file
        htop btop
        hyperfine
        jq
        killall
        mediainfo
        nh
        pass-wayland
        pv
        rsync
        sox
        speedtest-cli
        starship
        tmux tmuxp
        wget curl
        yazi
        zoxide

        # Nix / DevOps
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

        # ───────────────────────── Archiving ─────────────────────────
        p7zip
        rar #unrar #rar2fs
        unar # Allows for unzipping with Unicode characters.
        zip unzip 
	    #mdf2iso
        #torrent7z
        #xz
    ];
}
