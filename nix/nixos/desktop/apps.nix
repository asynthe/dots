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
            nemo-with-extensions
            networkmanagerapplet
            pavucontrol
            signal-desktop
            webcord
            zathura sioyek
            poppler-utils
        ];

        services.gvfs.enable = true;
        services.tumbler.enable = true;

        xdg.mime.defaultApplications."inode/directory" = "nemo.desktop";

        programs.dconf.profiles.user.databases = [{
            settings."org/cinnamon/desktop/default-applications/terminal" = {
                exec = "ghostty";
                exec-arg = "-e";
            };
            settings."org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                gtk-theme = "Adwaita-dark";
                font-name = "JetBrainsMono Nerd Font 10";
                monospace-font-name = "JetBrainsMono Nerd Font 14";
                document-font-name = "Noto Sans 14";
            };
        }];
    };
}
