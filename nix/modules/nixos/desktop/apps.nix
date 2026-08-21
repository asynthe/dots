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
            pavucontrol
            firefox arkenfox-userjs dejsonlz4
            #librewolf #mullvad-browser
            ungoogled-chromium
            mpv
            tidal-hifi
            webcord
            awww
            mpvpaper
            waypaper
            waybar
            zathura sioyek
        ];
    };
}
