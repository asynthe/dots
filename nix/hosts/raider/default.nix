{
    imports = [
        ./system.nix
        ./hardware.nix # Import hardware scan.

        ../../modules # TODO Remember to make the modules options once working.
        ../../profiles # Import all the custom options.
    ];
}
