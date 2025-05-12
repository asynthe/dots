{ pkgs, ... }: {

    # ───────────────────────── Hyprland ─────────────────────────
    programs = {
        hyprland = {
            enable = true;
            withUWSM = true;
        };
        #xwayland.enable = true;
    };

    # ───────────────────────── Packages ─────────────────────────
    environment.systemPackages = with pkgs; [
        brightnessctl
        grim slurp
        imv
        mako libnotify
        mpvpaper
        ripdrag
        rofi-wayland
        swayidle
        swww
        wl-clipboard
        libsForQt5.polkit-kde-agent
        libsForQt5.qt5.qtwayland
    ];
}
