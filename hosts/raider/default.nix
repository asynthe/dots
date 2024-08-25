{
    imports = [
        ../../profiles # Import all the custom options.

        ./disk.nix # Import disk configuration.
        ./hardware.nix # Import hardware scan.
        ./system.nix # Import custom configuration.

	    # Server
        ../../modules/srv/shell.nix
        ../../modules/pkgs/minimal.nix

        # Files to modularize
        #./files/pkgs.nix
        #./files/shell.nix
        #./files/user.nix
    ];
}
