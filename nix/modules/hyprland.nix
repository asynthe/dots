/*
https://hypr.land/plugins/

TODO Is there a option that stops Hyprland from installing if Cachix is enabled, or stops the process and ask to check not to install Hyprland with Cachix first but one and then the other

Cachix (enable if using git, rebuild with this then enable the git package)
    nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
};
*/

{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.hyprland;
in {
    options.sys.modules.hyprland = {
        enable = lib.mkEnableOption "Hyprland";
    };

    config = lib.mkIf cfg.enable {

        # TODO do waybar enable here
        programs.waybar.enable = true;

        # TODO do greetd enable here
        services.displayManager.defaultSession = "hyprland-uwsm";
        programs.hyprland = {
            enable = true;
            withUWSM = true; # TODO do greetd enable here
            #package = inputs.hyprland.packages.${pkgs.system}.hyprland; # git
        };

        environment.systemPackages = with pkgs; [

            # Apps
            gromit-mpx
            hyprshot
            imv
            mako libnotify
            ripdrag
            rofi walker
            socat # IPC
            swayidle
            wl-clipboard
            brightnessctl
            playerctl

            # Libs
            hyprpolkitagent
            libsForQt5.qt5.qtwayland
            adw-gtk3 # dark mode

            # Term
            alacritty
            ghostty
            wezterm
            kitty

            # GUI
            pavucontrol
            librewolf
            mpv
            tidal-hifi # music
            webcord #discord
            awww #inputs.awww.packages.${pkgs.system}.awww
            mpvpaper
            waypaper
            zathura sioyek
        ];
    };
}
