{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.xdg;
in {
    options.sys.modules.xdg = {
        enable = lib.mkEnableOption "XDG";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            xdg-ninja
        ];

        # environment.sessionVariables = {
        #     XDG_CONFIG_HOME = "$HOME/.config";
        #     XDG_DATA_HOME   = "$HOME/.local/share";
        #     XDG_CACHE_HOME  = "$HOME/.cache";
        #     XDG_STATE_HOME  = "$HOME/.local/state";
        #
        #     # Per-app redirects
        #     GNUPGHOME             = "$HOME/.config/gnupg";
        #     ANDROID_USER_HOME     = "$HOME/.config/android";
        #     WINEPREFIX            = "$HOME/wine_prefixes/default";
        #     NPM_CONFIG_USERCONFIG = "$HOME/.config/npm/npmrc";
        #     GRADLE_USER_HOME      = "$HOME/.local/share/gradle";
        #     EXPO_HOME             = "$HOME/.config/expo";
        # };
    };
}
