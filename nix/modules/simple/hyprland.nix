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
        imv
        mako libnotify
        pavucontrol
        ripdrag
        rofi-wayland
        swayidle
        wl-clipboard
        libsForQt5.polkit-kde-agent
        libsForQt5.qt5.qtwayland

        # Wallpaper
        mpvpaper
        inputs.swww.packages.${pkgs.system}.swww
        waypaper
    ];
}
