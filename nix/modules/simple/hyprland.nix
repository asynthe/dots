{ pkgs, inputs, ... }: {

    # ───────────────────────── Hyprland ─────────────────────────
    programs.hyprland = {
        enable = true;
        withUWSM = true;
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

    # Multi monitor script triggered by a udev rule
    #services.udev = {
    #    enable = true;
    #    extraRules = ''
    #      ACTION=="change", SUBSYSTEM=="drm", RUN+="/etc/udev/scripts/multi_monitor"
    #    '';
    #};

    # Multi monitor script
    #environment.etc."udev/scripts/multi_monitor".source = pkgs.writeShellScript "multi_monitor" ''
        #USER=meow
        #HOME_DIR="/home/$USER"
        #CONFIG_DIR="$HOME_DIR/.config/hypr"
        #OUTPUT_FILE="$CONFIG_DIR/monitor.conf"
        #LAYOUT_DIR="$CONFIG_DIR/modules"
        #MONITORS=$(sudo -u "$USER" hyprctl monitors -j | jq length)
        #case "$MONITORS" in
        #  1) cp "$LAYOUT_DIR/monitor_one.conf" "$OUTPUT_FILE" ;;
        #  2) cp "$LAYOUT_DIR/monitor_two.conf" "$OUTPUT_FILE" ;;
        #  3) cp "$LAYOUT_DIR/monitor_three.conf" "$OUTPUT_FILE" ;;
        #  *) echo "# Unknown monitor setup ($MONITORS)" > "$OUTPUT_FILE" ;;
        #esac
        #sudo -u "$USER" hyprctl reload
    #'';
}
