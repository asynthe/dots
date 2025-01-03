{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
	        imv # Image Viewer.
	        wallust # pywal, but mantained.
	        wl-clipboard # Clipboard.
            brightnessctl #brillo
            grim slurp # Screenshot
            hyprpicker # Color picker
            hyprshot # Screenshot
            mako libnotify # Notification daemon.
            mpvpaper # Video wallpaper.
            ripdrag # Drag & Drop.
            swayidle # Idle daemon.
            wdisplays #wlr-randr #kanshi
            wofi # App launcher.
	    ;
        inherit (pkgs.libsForQt5) polkit-kde-agent; # Authentication Agent
        inherit (pkgs.libsForQt5.qt5) qtwayland;
        #inherit (pkgs.qt6) qtwayland; # Qt Wayland Support
        #inherit (pkgs.xorg) xlsclients; # Check for apps running on xwayland
        #inherit (pkgs.xfce) xfce4-terminal mousepad;
    };
}
