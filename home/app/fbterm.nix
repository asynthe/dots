{ config, pkgs, ... }: {

    #users.users.${user}.extraGroups = [ "video" ]; # Not a Home Manager option.
    home = {
        packages = builtins.attrValues {
            inherit (pkgs)
                fbterm
                fbcat
            ;
        };
        file.".config/fbtermrc".source = config.lib.file.mkOutOfStoreSymlink ../../../dots/fbtermrc;
    };
}
