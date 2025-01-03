{ config, lib, pkgs, ... }: {

    programs.zsh.sessionVariables = lib.mkIf config.programs.zsh.enable { 
        BROWSER = "librewolf"; 
    };

    programs.librewolf = {
        enable = true;
        #package = ;
        settings = {
            #"browser.startup.homepage" = "https://kagi.com";
            "network.cookie.lifetimePolicy" = 0;
            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown.downloads" = false;
            "privacy.clearOnShutdown.history" =  false;
            "privacy.resistFingerprinting" = false;
            "webgl.disabled" = false; # Breaks Maps and similar.

            "browser.download.panel.shown" = true;
            "media.peerconnection.ice.no_host" = false; # WebRTC.
            "media.eme.enabled" = true; # DRM.
        };
    };

    home.packages = builtins.attrValues {
        inherit (pkgs)
            # Decompress bookmarks backup files
            dejsonlz4
        ;
    };
}
