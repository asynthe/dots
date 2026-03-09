{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;
  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    stateVersion = "25.11"; # Check the one you have on the original file and don't change it.
    packages = with pkgs; [ neovim ];
    #file = { };
    #sessionVariables = { }; # EDITOR = "nvim"
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi

      export NIX_SHELL_PRESERVE_PROMPT=1
      if [[ -n "$IN_NIX_SHELL" ]]; then
        export PS1="$PS1(nix-shell) "
      fi
    '';
  };
}
