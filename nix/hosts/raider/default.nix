{
    imports = [
        ./system.nix
        ./hardware.nix # Import hardware scan.
        ../../profiles # Import all the custom options.
    ];
}
