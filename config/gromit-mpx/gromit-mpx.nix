{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
            gromit-mpx
        ;
    };

    #services.gromit-mpx = {
    #    enable = true;
    #};
}
