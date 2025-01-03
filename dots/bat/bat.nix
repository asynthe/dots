{ config, pkgs, ... }: {

    #programs.bat.enable = true;
    home.packages = builtins.attrValues { inherit (pkgs) bat; };
    programs.zsh.shellAliases = {
        cat = "bat";
    };
}
