{ config, inputs, pkgs, ... }: {

    # -------------- Hyprland --------------
    #xdg.configFile."hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink ./hyprland.conf;

    # Configuration 
    wayland.windowManager.hyprland = {
        xwayland.enable = true; # Steam
        systemd.enable = false;

        # Plugins
        plugins = [
            inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
        ];
    };

    # Packages
    home.packages = builtins.attrValues {
        inherit (pkgs)
            hyprland
            wofi
            pavucontrol
            hyprshot
            swappy
            brightnessctl
        ;
        inherit (pkgs.libsForQt5)
            polkit-kde-agent
        ;
    };

    # XDG Portal for screensharing
    xdg.portal = {
        enable = true;
        config.hyprland.default = [ "hyprland" "gtk" ];
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [ 
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
        ];
    };

    # Create a target session for hyprland
    systemd.user.targets.hyprland-session = {
        Unit = {
            Description = "Hyprland compositor Session";
            Documentation = [ "man:systemd.special(7)" ];
            BindsTo = [ "graphical-session.target" ];
            Wants = [ "graphical-session-pre.target" ];
            After = [ "graphical-session-pre.target" ];
        };
    };

    # Home-Manager system tray
    systemd.user.targets.tray = {
        Unit = {
            Description = "Home Manager System Tray";
            Requires = [ "graphical-session-pre.target" ];
        };
    };
}
