{ config, pkgs, ... }: {

    #xdg.configFile = {
    #    "nushell/config.nu".source = config.lib.file.mkOutOfStoreSymlink ./config.nu;
    #    "nushell/env.nu".source = config.lib.file.mkOutOfStoreSymlink ./env.nu;
    #};

    home.packages = builtins.attrValues {
        inherit (pkgs)
            nushell
        ;
    };
}
