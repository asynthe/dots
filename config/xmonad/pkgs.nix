{ pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
            dmenu
            nitrogen # Wallpaper setter
            nsxiv # Image viewer
            xmobar
        ;
  };

}
