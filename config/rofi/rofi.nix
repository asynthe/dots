{ config, pkgs, ... }: {

    home.packages = builtins.attrValues { 
        inherit (pkgs) 
            rofi-wayland
        ;
    };

    #xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink ./config.rasi;
}
