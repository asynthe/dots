{ config, pkgs, ... }: {

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  environment.systemPackages = with pkgs; [
    pass-wayland
    pinentry-curses # redundant?
  ];
}
