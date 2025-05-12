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
}
