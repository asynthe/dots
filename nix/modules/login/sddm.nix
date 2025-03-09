{ pkgs, inputs, ... }: {

    # Tried to get where-is-my-sddm-theme working, to no avail.

    programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;
    };

    services.displayManager = {
        defaultSession = "hyprland";
        sddm = {
            enable = true;
            enableHidpi = true;
            wayland.enable = true;
            theme = "where-is-my-sddm-theme";
        };
    };

    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
            where-is-my-sddm-theme
        ;
    };
}
