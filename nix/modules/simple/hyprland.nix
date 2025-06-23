{ pkgs, inputs, ... }: {

    # ───────────────────────── Hyprland ─────────────────────────
    programs.hyprland = {
        enable = true;
        withUWSM = true;
    };

    programs.waybar.enable = true;
    xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
        ];
    };

    # ───────────────────────── Packages ─────────────────────────
    environment.systemPackages = with pkgs; [
        brightnessctl
        grim slurp
        gromit-mpx
        hyprshot
        imv
        libsForQt5.polkit-kde-agent
        libsForQt5.qt5.qtwayland
        mako libnotify
        pavucontrol
        ripdrag
        rofi-wayland
        socat # IPC
        swappy
        swayidle
        wl-clipboard

        # Wallpaper
        mpvpaper
        swww #inputs.swww.packages.${pkgs.system}.swww
        waypaper
    ];
}
