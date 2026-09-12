# Wayland shells: the bar, launcher, notifier and lockscreen layer. Kept out of the
# `hyprland` session bundle because a shell is a choice a host opts into.
{ ... }:
{
    # Toolkit, not a shell: nothing runs until the runner is pointed at a config.
    flake.modules.nixos.quickshell = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            quickshell
            # qmlls, qmlformat, qmllint -- editing the config is the whole job here.
            qt6.qtdeclarative
        ];
        # Configs shell out to their own tools; hyprquickpaper's all come from elsewhere.
    };

    # Qt5Compat.GraphicalEffects is not on the QML path from systemPackages alone.
    flake.modules.nixos.quickshell-tide-island = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.qt6.qt5compat ];
        environment.sessionVariables.QML2_IMPORT_PATH =
            "${pkgs.qt6.qt5compat}/lib/qt-6/qml";
        # tide-island installs to ~/.local and resolves its config app off PATH.
        environment.localBinInPath = true;
    };
}
