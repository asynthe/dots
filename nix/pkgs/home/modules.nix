{ config, pkgs, ... }: {
    imports = [

        # TODO Fix Priority
        ../nix/pkgs/home_modules/mpd.nix

        # TODO Modules to reduce and delete
        # MODIFY AND REMOVE FROM HOME
	    #../home_modules/vscode
	    #../home_modules/xmonad.nix
	     ../home_modules/librewolf.nix
        #../home_modules/spotifyd.nix
        #../home_modules/swappy.nix
        #../home_modules/swayidle.nix
         ../home_modules/mpv.nix

        # -------------------------------------------------
        # Remember to first rebuild home manager with 
        # the specified cache then enable the dotfile .
        ./substituters.nix

        # Hyprland
        ../../config/hypr
        # Wezterm
        # Yazi

        # -------------- Package modules and other --------------

	    # System
        ./home_modules/fonts.nix
        ./home_modules/settings.nix
        ./home_modules/stylix.nix
        ./home_modules/xdg.nix

        # Shell
        ./home_modules/aliases.nix
        ./home_modules/bash.nix
        ./home_modules/plugins.nix
        ./home_modules/zsh.nix
    ];
}
