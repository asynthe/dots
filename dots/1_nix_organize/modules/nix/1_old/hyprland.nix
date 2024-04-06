{
  pkgs,
  inputs,
  lib,
  username,
  ...
}: let
  filePath = ./hyprland.conf;
  fileContent = builtins.readFile filePath;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland; # If using the flake.
    #settings = ;
    extraConfig = "${fileContent}";
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1"; # Session variable for Electron apps.
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
    # XDG Portal
    #xdg-desktop-portal-hyprland

    # Apps
    eww-wayland # status bar
    wofi #bemenu
    gtklock # lock screen
    swayidle # idle daemon
    imv # image viewer
    nsxiv # image viewer (X11)
    grim
    slurp # simple screenshot
    mako
    libnotify # notification daemon
    wlogout
    pass-wayland # password manager

    swww #wpaperd # wallpaper daemon
    mpvpaper # video wallpaper

    wl-clipboard
    wdisplays #wlr-randr #kanshi
    brightnessctl #brillo

    # Testing
    waybar

    # Not used
    #nwg-bar
    #nwg-menu
    #nwg-panel
    #nwg-drawer
    #nwg-wrapper
    #nwg-launchers
    #swaylock-effects

    # Must have
    polkit
    ;
    inherit (pkgs.xorg) xlsclients; # Check for apps running on xwayland.
    inherit (pkgs.libsForQt5) polkit-kde-agent; # Authentication Agent.
    inherit (pkgs.libsForQt5.qt5) qtwayland; # Qt Wayland Support.
    inherit (qt6) qtwayland; # Qt Wayland Support.
  };
}
