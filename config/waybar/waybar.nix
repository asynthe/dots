{ config, pkgs, lib, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
            waybar
        ;
    };

    home.file = {
        ".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink ./config.jsonc;
        ".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink ./style.css;
    };
}
