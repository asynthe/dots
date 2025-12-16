{
    imports = [
        ./system.nix
        ./hardware.nix # Import hardware scan.
        ../../profiles # Import all the custom options.

        # Simple Modules
        ../../modules/simple/gpg.nix
        ../../modules/simple/hyprland.nix
        ../../modules/simple/ime.nix
        ../../modules/simple/neovim.nix
        ../../modules/simple/obs-studio.nix

        # Packages
        ../../pkgs/set/fonts.nix
        ../../pkgs/set/fonts_jp.nix
        ../../pkgs/set/minimal.nix
        ../../pkgs/set/minimal_extra.nix
        ../../pkgs/set/wm.nix
    ];
}
