{
    imports = [

    	# We are going to have to move stuff
	    # from pkgs to pkgs minimal
	    # or to another tools, idk
	    # We need more cli shit.
        ../../../dots/home/pkgs/minimal.nix
        ../../../dots/home/pkgs/cli.nix
        #../../dots/home/pkgs/gui.nix

        # GUI
        ../../../dots/home/app/emacs

	    # Imports
	    ../../../dots/home/app/nvim
	    ../../../dots/home/app/lf
	    ../../../dots/home/app/gpg

	    # Imports - Single Files
	    #../../dots/home/app/bash.nix
	    ../../../dots/home/app/bat.nix
	    ../../../dots/home/app/direnv.nix
	    ../../../dots/home/app/eza.nix
	    ../../../dots/home/app/git.nix
	    ../../../dots/home/app/starship.nix
	    ../../../dots/home/app/tmux.nix
        ../../../dots/home/app/zoxide.nix
        ../../../dots/home/app/zsh.nix
        
        # System
        ../../../dots/home/sys/fonts.nix
        ../../../dots/home/sys/settings.nix
        ../../../dots/home/sys/stylix.nix
        #../../../dots/home/sys/uutils-replace.nix
        ../../../dots/home/sys/var.nix
        #../../dots/home/sys/xdg.nix
    ];
}
