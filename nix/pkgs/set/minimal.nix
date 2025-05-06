{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # --------------- Testing ---------------
        bcachefs-tools
        fbterm # -> Set 'video' user group
        fbcat
	    #ciscoPacketTracer8
	    #gns3-gui gns3-server

        # --------------- CLI ---------------
	    ascii
	    bc
	    fd ripgrep
	    fzf skim
	    git bfg-repo-cleaner
	    libqalculate
	    ncdu
        htop btop
        httpie
        jq
        killall
        lsof
        neovim # If enabled, disable the dots import version.
        pass-wayland
        rsync
        tmux tmuxp
        tree
        usbutils
        wget curl
        pv

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
