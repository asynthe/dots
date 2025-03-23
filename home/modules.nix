{
    imports = [

        # TODO Modules to reduce and delete
        # MODIFY AND REMOVE FROM HOME
	    ./modules/mpvpaper.nix
	    ./modules/nh.nix
	    #./modules/xmonad.nix
        ./modules/bat.nix
        ./modules/direnv.nix
        ./modules/eza.nix
        ./modules/mpd.nix
        ./modules/mpv.nix
        ./modules/swww.nix
        ./modules/wayfire.nix
        ./modules/wezterm.nix
        ./modules/wofi.nix
        ./modules/yazi.nix
        ./modules/zathura.nix
        ./modules/zoxide.nix
	    ./modules/librewolf.nix

        # Hyprland
        ../config/hypr

        # -------------------------------------------------
        # Remember to first rebuild home manager with 
        # the specified cache then enable the dotfile .
        ./sys/substituters.nix
        # - Hyprland
        # - Wezterm
        # - Yazi

        # -------------- Package modules and other --------------

	    # System
        ./sys/fonts.nix
        ./sys/fonts.nix
        ./sys/jp.nix
        ./sys/settings.nix
        ./sys/stylix.nix
        ./sys/xdg.nix

        # -------------- Remove from here down !!! --------------

        ./app/mapscii.nix
        ./app/microsoft-edge.nix
        ./app/gpg
	    #./app/vscode

        ./app/fbterm.nix
        ./app/git.nix
	    ./app/mako.nix
        ./app/microsoft-edge.nix
        ./app/obs.nix
        #./app/spotifyd.nix
        #./app/swappy.nix
        #./app/swayidle.nix
        #./app/swayosd.nix
        #./app/uwsm.nix

        # Package Sets # REDUCE
        ./pkgs/audio.nix
        ./pkgs/cli.nix
        ./pkgs/gui.nix
        ./pkgs/minimal.nix
        #./pkgs/sec.nix
        ./pkgs/pkgs.nix
        ./pkgs/stable.nix

        # Shell
        ./shell/aliases.nix
        ./shell/bash.nix
        ./shell/plugins.nix
        ./shell/zsh.nix

        # systemd services + timers
        ./sysd/backup_web.nix
    ];
}
