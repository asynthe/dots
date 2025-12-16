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
        pkgs-stable.tectonic #tectonic # LaTeX Engine

        # Filesystem tools
		fio
		hdparm
		nvme-cli
        bcachefs-tools
        gptfdisk
        parted

        # Networking
        httpie

        # Nvidia
        #nvtopPackages.full #pkgs-stable.nvtopPackages.full
        #nvtopPackages.nvidia

        # ───────────────────────── CLI ─────────────────────────
	    ascii

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
