{
  pkgs,
  lib,
  ...
}: {
  home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      xmonad-with-packages
      ;
  };
}
