{ config, ... }: {

    # -------------- XDG --------------
    xdg = {
        configHome = "${config.home.homeDirectory}/.config";
        userDirs = {
            enable = true;
            createDirectories = false;
            music = "${config.home.homeDirectory}/sync/archive/music";
        };
    };

    home.sessionVariables = {
        XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
        XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
        XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Downloads/screenshots";
        XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
    };

    #home.packages = builtins.attrValues {
        #inherit (pkgs)
            #xdg-utils # xdg-mime, xdg-open
            #xdg-ninja # checks $HOME for unwanted files and directories.
            #xdg-user-dirs
        #;
    #};

    # Testing running discord with ozone variables and offload
    #xdg.desktopEntries.discord = {
    #name = }

    #xdg = {
    #    enable = true;
    #    cacheHome = config.home.homeDirectory + "/.local/cache";
    #    mime.enable = true; # XDG MIME
    #};
    #mimeApps = {
    #  enable = true;
    #  defaultApplications = let
    #    browser = ["firefox.desktop"];
    #  in {
    #    "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    #    "text/csv" = "calc.desktop";
    #    "text/x-lua" = "nvim";
    #
    #    "text/html" = browser;
    #    "text/xml" = browser;
    #    "application/xml" = browser;
    #    "application/xhtml+xml" = browser;
    #    "application/xhtml_xml" = browser;
    #    "application/rdf+xml" = browser;
    #    "application/rss+xml" = browser;
    #    "application/x-extension-htm" = browser;
    #    "application/x-extension-html" = browser;
    #    "application/x-extension-shtml" = browser;
    #    "application/x-extension-xht" = browser;
    #    "application/x-extension-xhtml" = browser;
    #    "x-scheme-handler/about" = browser;
    #    "x-scheme-handler/ftp" = browser;
    #    "x-scheme-handler/http" = browser;
    #    "x-scheme-handler/https" = browser;
    #    "x-scheme-handler/unknown" = browser;
    #
    #    "x-scheme-handler/discord" = ["discord.desktop"];
    #    "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
    #
    #    "audio/*" = ["mpv.desktop"];
    #    "video/*" = ["mpv.desktop"];
    #
    #    "image/*" = ["imv.desktop"];
    #    "image/gif" = ["imv.desktop"];
    #    "image/jpeg" = ["imv.desktop"];
    #    "image/png" = ["imv.desktop"];
    #    "image/webp" = ["imv.desktop"];
    #  };
    #  associations = {
    #    added = {
    #      "application/x-subrip" = "mpv.desktop";
    #    };
    #
    #    #removed = ;
    #    #"..." = "...";
    #    #};
    #  };
    #};
    #};
}
