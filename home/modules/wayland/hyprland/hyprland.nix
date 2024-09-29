{ config, inputs, lib, pkgs, ... }: {

    # I tried bro
    #home.file.".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink ../../../../dots/hypr/hyprland.conf;

    wayland.windowManager.hyprland = {
        enable = true;
        #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;
        #systemd = {
            #enable = true;
            #variables = [ "--all" ];
            #extraCommands = lib.mkBefore [
                #"systemctl --user stop graphical-session.target"
                #"systemctl --user start hyprland-session.target"
            #];
        #};
    };
    
    xdg.portal = {
        xdgOpenUsePortal = true;
        configPackages = [ inputs.hyprland.packages.${pkgs.system}.hyprland ];
        extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
    };
}
