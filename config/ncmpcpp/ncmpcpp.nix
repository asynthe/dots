{ config, pkgs, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) ncmpcpp; };
    #xdg.configFile = {
        #"ncmpcpp/bindings".source = config.lib.file.mkOutOfStoreSymlink ./bindings;
        #"ncmpcpp/config".source = config.lib.file.mkOutOfStoreSymlink ./config;
    #};
}
