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

        # mkOutOfStoreSymlink
	    ../../../dots/ncmpcpp
        ../../../dots/cava
        ../../../dots/direnv
        ../../../dots/emacs
        ../../../dots/hypr # Hyprland
        ../../../dots/nvim # Using nixvim so I'll leave it like that.
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

        # Shell
        ../../shell/aliases.nix
        ../../shell/bash.nix
        ../../shell/plugins.nix
        ../../shell/zsh.nix

        # systemd services + timers
        ../../sysd/backup_web.nix
    ];
}
