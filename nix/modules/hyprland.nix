{ pkgs, ... }: {

    # --------------- Hyprland ---------------
    programs = {
        hyprland = {
            enable = true;
            withUWSM = true;
        };
        #xwayland.enable = true;
    };
    environment.systemPackages = with pkgs; [
        brightnessctl
        grim slurp
        imv
        mako libnotify
        mpvpaper
        ripdrag
        swayidle
        swww
        wl-clipboard
        wofi
        libsForQt5.polkit-kde-agent
        libsForQt5.qt5.qtwayland
    ];
}
