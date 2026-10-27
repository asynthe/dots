{ ... }:
{
    flake.modules.nixos.theme = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
        ];

        environment.sessionVariables = {
            GTK_THEME = "adw-gtk3-dark";
            QT_QPA_PLATFORMTHEME = "gtk3";
        };
    };
}
