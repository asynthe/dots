{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    ffmpeg-full
    git bfg-repo-cleaner
    imagemagick
    neovim
    nh
    tree
    yazi

    # GUI
    ghostty
  ];
}
