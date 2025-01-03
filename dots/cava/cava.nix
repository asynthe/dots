{ pkgs, ... }: {

    #home.packages = builtins.attrValues { inherit (pkgs) cava; };
    programs.cava.enable = true;

}
