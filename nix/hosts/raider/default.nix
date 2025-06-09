{
    imports = [
        ./system.nix
        ./hardware.nix # Import hardware scan.
        ../../profiles # Import all the custom options.

        # Modules
        ../../modules/simple/ime.nix
        ../../modules/simple/gpg.nix
        ../../modules/simple/hyprland.nix
        ../../modules/simple/neovim.nix

        # Packages
        ../../pkgs/set/fonts.nix
        ../../pkgs/set/minimal.nix
        ../../pkgs/set/wm.nix
    ];
}
