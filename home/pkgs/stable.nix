{ pkgs-stable, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs-stable)
            tectonic;
    };
}
