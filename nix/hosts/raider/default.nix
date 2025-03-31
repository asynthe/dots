{
    imports = [
        ../../modules # TODO Remember to make the modules options once working.
        ../../profiles # Import all the custom options.
        ../../pkgs # Import package sets.

        ./hardware.nix # Import hardware scan.
        ./system.nix # Import custom configuration.
    ];
}
