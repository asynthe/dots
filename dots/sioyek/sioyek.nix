{ pkgs, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) sioyek; };
    #xdg.configFile."sioyek/keys_user.config".source = config.lib.file.mkOutOfStoreSymlink ./keys_user.config;
}
