{ ... }:
{
    flake.modules.nixos.terminals = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            alacritty
            ghostty
            kitty
            warp-terminal
            wezterm
        ];
    };

    flake.modules.nixos.desktop-apps = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            firefox arkenfox-userjs dejsonlz4
            #librewolf #mullvad-browser
            ungoogled-chromium
            imv
            mpv
            networkmanagerapplet
            pavucontrol
            signal-desktop
            tidal-hifi
            webcord
            zathura sioyek
            poppler-utils
        ];
    };
}
