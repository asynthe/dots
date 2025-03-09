{ config, pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs) 
            tmux 
            tmuxp
        ; 
    };

    xdg.configFile = {
        "tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink ./tmux.conf;
    };
}
