{ config, ... }:
{
  # Hyprland session and graphical apps.
  flake.modules.nixos.profile-desktop = {
    imports = with config.flake.modules.nixos; [
      hyprland
      hyprglass
      autologin
      quickshell
      terminals
      desktop-apps
      firefox
      fonts
      theme
      xdg
      ime
    ];
  };
}
