# Wayland desktop shells: the bar, launcher, notifier and lockscreen layer.
#
# Kept out of the `hyprland` aspect on purpose. That aspect is the fixed
# session bundle (waybar, mako, fuzzel) every Hyprland host gets; a shell is a
# choice between alternatives, so it gets its own name and a host opts in.
{ ... }:
{
    # Toolkit, not a shell. Ships the `quickshell` runner and nothing else runs
    # until it is pointed at a config -- ~/.config/quickshell/<name>/shell.qml,
    # or `quickshell -p <path>`.
    flake.modules.nixos.quickshell = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            quickshell
            # qmlls, qmlformat, qmllint -- editing the config is the whole job here.
            qt6.qtdeclarative
        ];
        # Configs shell out to their own tools. hyprquickpaper wants jq and
        # magick (cli.nix) and awww (hyprland); nothing to add here for it.
        # A config that imports QML beyond qtdeclarative/qtsvg needs quickshell
        # wrapped with QML2_IMPORT_PATH -- systemPackages will not do it.
    };
}
