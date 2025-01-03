{ config, pkgs, ... }: {

    # Do this so emacs works with the dots.
    # ln -sf $HOME/sync/flake/dots/emacs/init.el $HOME/.config/emacs/init.el
    # ln -sf $HOME/sync/flake/dots/emacs/README.el $HOME/.config/emacs/README.el

    #home.file.".config/emacs/README.org".source = config.lib.file.mkOutOfStoreSymlink ./README.org;
    #xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink ../emacs;

    home.packages = builtins.attrValues {
        inherit (pkgs)
            emacs29-pgtk
            hunspell
        ;

        # Emacs Packages
        #inherit (pkgs.emacsPackages)
            #doom-modeline
            #doom-modeline-now-playing # Requires playerctl.
        #;

        # Hunspell dictionaries
        inherit (pkgs.hunspellDicts)
            #fr-moderne # French (modern) from Dicollecte
            #es_MX # Spanish (Mexico) from rla
            #es_mx # Spanish (Mexico) from rla
            #es_CL # Spanish (Chile) from rla ?
            #es_cl
            en_US # English (United States) from Wordlist
            #en-us
            en_AU # English (Australia) from Wordlist
            #en-au
        ;
    };
}
