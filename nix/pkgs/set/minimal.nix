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
        #neovim # If enabled, disable the dots import version.
        #ollama
        acpi
        cava
        emacs30-pgtk
        ffmpeg-full
        git
        htop btop
        httpie
        imagemagick
        jq
        killall
        lsof
        neovim
        nh
        pass-wayland
        pv
        rsync
        tmux tmuxp
        tree
        usbutils
        wget curl
        yazi

        # GUI
        #ghostty
        #...

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
