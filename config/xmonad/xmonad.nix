{ configs, pkgs, ... }: {

    services.xserver.windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        #config = builtins.readFile ./xmonad.hs
    };
};
