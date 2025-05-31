{
    # IMPORTANT
    # This configuration uses the Flake version of Hyprland, cache is required if you don't
    # want to be compiling Hyprland all the time, for that, follow the next steps.
    # 1. Build system without Hyprland, but with Hyprland cachix enabled. (enable only ./cache.nix)
    # 2. Uncomment and build system with Hyprland, it should now take the binaries from the cache.

    imports = [
        ./module/cache.nix # Enable this first.

        #./configuration.nix  # Enable this second.
        #./hyprland.nix # Enable this second.
    ];
}
