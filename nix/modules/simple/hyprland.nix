{ pkgs, inputs, ... }: {

    # ───────────────────────── Hyprland ─────────────────────────
    programs.hyprland = {
        enable = true;
        withUWSM = true;
    };

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
    programs.waybar.enable = true;
    environment.systemPackages = with pkgs; [
        brightnessctl
        grim slurp
        gromit-mpx
        hyprshot
        imv
        mako libnotify
        pavucontrol
        ripdrag
        rofi
        socat # IPC
        swappy
        swayidle
        wev
        wl-clipboard

        # Libs
        hyprpolkitagent
        libsForQt5.qt5.qtwayland

        # Wallpaper
        mpvpaper
        swww #inputs.swww.packages.${pkgs.system}.swww
        waypaper
    ];
}
