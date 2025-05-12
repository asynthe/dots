{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # ───────────────────────── CLI ─────────────────────────
	    ascii
	    bc
	    fd ripgrep
	    fzf skim
	    git bfg-repo-cleaner
	    libqalculate
	    ncdu
        acpi
        htop btop
        httpie
        imagemagick
        jq
        killall
        lsof
        #neovim # If enabled, disable the dots import version.
        nh
        pass-wayland
        pv
        rsync
        tmux tmuxp
        tree
        usbutils
        wget curl
        yazi

	    # Filesystem tools
		fio
		hdparm
		nvme-cli
        gptfdisk
        usbutils

        # Archiving
	    #mdf2iso
        p7zip
        rar #unrar #rar2fs
        #torrent7z
        unar # Allows for unzipping with Unicode characters.
        #xz
        zip unzip 
    ];
}
