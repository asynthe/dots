{ config, lib, pkgs, ... }: 
let
    locale = "en_US.UTF-8";
in {

    # -------------- Nix / Home Manager --------------
    news.display = "silent";
    nix.package = pkgs.nix;
    nix.settings = {
        warn-dirty = false;
        extra-experimental-features = [ "nix-command" "flakes" ];
        #substituters = lib.mkBefore [ "https://cache.nixos.org" ];
        #trusted-public-keys = lib.mkBefore [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    # Fix for nixpkgs.allowUnfree = true
    # https://discourse.nixos.org/t/unfree-packages-on-flake-based-home-manager/30231
    nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
    };

    # -------------- coreutils in Rust --------------
    # Replace coreutils with uutils.
    # https://discourse.nixos.org/t/how-to-use-uutils-coreutils-instead-of-the-builtin-coreutils/8904/4
    #home.packages = [ (pkgs.uutils-coreutils.override {prefix = "";}) ];

    # -------------- Variables --------------
    i18n.glibcLocales = pkgs.glibcLocales; # Fixing stuff
    home.sessionVariables = {
        TERMINAL = "${pkgs.wezterm}/bin/wezterm";
        EDITOR = "${pkgs.neovim}/bin/nvim";
	    VISUAL = "${pkgs.neovim}/bin/nvim";
        LC_ALL = locale;
        LANG = locale;
    };
}
