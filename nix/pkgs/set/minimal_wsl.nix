{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    ffmpeg-full
    git bfg-repo-cleaner
    imagemagick
    neovim
    nh
    sioyek
    tree
    yazi

    # GUI
    ghostty
  ];
}
