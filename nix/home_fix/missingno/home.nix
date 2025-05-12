{ config, pkgs, user, ... }: {

    programs.home-manager.enable = true;

    home = {
        username = user;
        homeDirectory = "/home/${user}";
        stateVersion = "24.05";
        packages = [ pkgs.nix ];
        sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/nixpkgs";
        language.base = "en_US.UTF-8";
    };
}
