{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    cava
    emacs30-pgtk
    ffmpeg-full
    git
    imagemagick
    neovim
    nh
    #ollama
    superfile
    yazi

    # GUI
    #ghostty
    #...
    
  ];

  # Fonts
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.fira-code
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      nerd-fonts.mononoki
      nerd-fonts.mplus
      nerd-fonts.overpass
      nerd-fonts.sauce-code-pro
      nerd-fonts.ubuntu-sans
      nerd-fonts.zed-mono
    ];
  };
}
