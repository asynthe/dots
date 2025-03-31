{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # --------------- Testing ---------------
        bcachefs-tools
        fbterm # -> Set 'video' user group
        fbcat
	    #ciscoPacketTracer8
	    #gns3-gui gns3-server

        # --------------- CLI ---------------
        pass-wayland

        # CLI
	    bc
	    fd ripgrep
	    fzf skim
	    git
	    ncdu
        curl
        htop btop
        jq
        killall
        lsof
        #neovim # If enabled, disable the dots import version.
        rsync
        tree
        wget

	    ascii
        httpie
        usbutils

	    # Filesystem tools
		fio
		hdparm
		nvme-cli

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
