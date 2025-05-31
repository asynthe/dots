{
    imports = [
        ./disk.nix
        ./system.nix

        ../../profiles # Import all the custom options.
        ./hardware/libvirt-hardware.nix # Import hardware scan.

	    # Server
        ../../modules/srv/shell.nix
        ../../modules/pkgs/minimal.nix
    ];
}
