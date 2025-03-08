{
    imports = [

        # Substituters and Binary Cache
        # -------------------------------------------------
        # Remember to first rebuild home manager with 
        # the specified cache then enable the dotfile .
        ../../sys/substituters.nix
        # - Hyprland
        # - Wezterm
        # - Yazi

        # testing - not yet
        ../../../dots/rofi
	    ../../../dots/mpd
        ../../../dots/mpv
        ../../../dots/nushell

        # While `mkOutOfStoreSymlink` is just what i need
        # I don't feel like rebuilding home all the time
        # So I'll just install the programs with `home.packages`
        # And dotfile -> symlink like always
	    ../../../dots/ncmpcpp
        ../../../dots/cava
        ../../../dots/direnv
        ../../../dots/emacs
        ../../../dots/gromit-mpx
        ../../../dots/hypr
        ../../../dots/nvim
        ../../../dots/sioyek
        ../../../dots/starship
        ../../../dots/tmux
        ../../../dots/vis
        ../../../dots/waybar
        ../../../dots/wayfire
        ../../../dots/wezterm
        ../../../dots/wofi
        ../../../dots/zathura

        # Non-existent config file but appends to something 
	    ../../../dots/bat
	    ../../../dots/mpvpaper
        ../../../dots/eza
        ../../../dots/nh
        ../../../dots/zoxide
	    ../../../dots/swww # FIX

        # Stylix modified
	    ../../../dots/alacritty
        ../../../dots/yazi
        # Kitty

        # -------------- Package modules and other --------------

	    # System
        ../../sys/fonts.nix
        ../../sys/fonts.nix
        ../../sys/jp.nix
        ../../sys/settings.nix
        ../../sys/stylix.nix
        ../../sys/xdg.nix

        # -------------- Remove from here down !!! --------------
        ../../app/mapscii.nix
        ../../app/microsoft-edge.nix
        ../../app/obs.nix

	    # FIND PROBLEM with sql rust thing !!!
	    # Apps
        ../../../dots/ghostty
        ../../../dots/zellij
        ../../app/superfile.nix
        ../../app/uwsm.nix
        ../../app/gpg
	    ../../app/librewolf
	    #../../app/vscode
        # Apps - Single Files
        ../../app/fbterm.nix
        ../../app/git.nix
	    ../../app/mako.nix
        ../../app/swappy.nix
        #../../app/swayidle.nix
        #../../app/swayosd.nix
        #../../app/spotifyd.nix

        # Package Sets # REDUCE
        ../../pkgs/audio.nix
        ../../pkgs/cli.nix
        ../../pkgs/gui.nix
        ../../pkgs/minimal.nix
        #../../pkgs/sec.nix
        ../../pkgs/pkgs.nix
        ../../pkgs/stable.nix

        # Shell
        ../../shell/aliases.nix
        ../../shell/bash.nix
        ../../shell/plugins.nix
        ../../shell/zsh.nix

        # systemd services + timers
        ../../sysd/backup_web.nix
    ];
}
