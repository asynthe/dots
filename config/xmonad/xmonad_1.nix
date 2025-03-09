{pkgs, ...}: {
  ##### X11 #####

  #services.xserver = {
  #xkbOptions = "ctrl:swapescape";
  #displayManager = {
  # STARTX
  #startx.enable = true;
  # GDM
  #gdm = {
  #enable = true;
  #wayland = true;
  #};
  # SDDM
  #sddm = {
  #enable = true;
  #};
  #};
  # TWM - XMONAD
  #windowManager.xmonad = {
  #enable = true;
  #enableContribAndExtras = true;
  #};
  #libinput = {
  #enable = true;
  #touchpad = {
  #naturalScrolling = false;
  #middleEmulation = false;
  #tapping = true;
  #};
  #};
  #};

  environment.systemPackages = with pgks; [
    # GUI
    haskellPackages.xmobar
    dmenu
    picom-jonaburg # compositor
    lxappearance #lxappearance-gtk2
    nitrogen
    xorg.xprop
    xorg.xinit
    xclip
    nsxiv # image viewer
  ];
}
