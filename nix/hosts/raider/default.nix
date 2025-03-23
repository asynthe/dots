{
    imports = [
        ../../profiles # Import all the custom options.

        ./disk.nix # Import disk configuration.
        ./hardware.nix # Import hardware scan.
        ./system.nix # Import custom configuration.
        ./pkgs.nix
    ];
}
