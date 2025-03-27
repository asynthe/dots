{ config, pkgs, ... }: {

        #shellAliases = {
        #};
    #};

    # REMOVE: direnv
    # REMOVE: Yazi 
    # REMOVE: Zoxide
    # REMOVE: zathura
    programs.zsh = {

        # REMOVE: STARSHIP
        # REMOVE: Wayfire
        # REMOVE: nh
        # REMOVE: pass
        sessionVariables = {
            #READER = "zathura";
            STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
            WAYFIRE_CONFIG_FILE = "$HOME/.config/wayfire/wayfire.ini";
            FLAKE = "$HOME/dots";
            PASSWORD_STORE_DIR = "$HOME/pass/pass";
        };

        initExtra = ''
# direnv
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Starship
eval "$(starship init zsh)"

# Yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
        '';
        shellAliases = {

            # REMOVE: wezterm
            #img = "wezterm imgcat";

            # REMOVE: zathura
	        #pdf = "zathura";
	        #book = "${pkgs.fd}/bin/fd . ~/sync/archive/book/reading --type f -e 'pdf' -e 'epub' | ${pkgs.skim}/bin/sk | xargs zathura & disown"; # TODO Redirect output to /dev/null (?)

            # REMOVE: bat
            cat = "bat";

            # REMOVE: yazi
            lf = "yy";
            f = "yy";
            yazi = "yy";

            # REMOVE: mpvpaper
	        video = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf --no-resume-playback --panscan=1' '*'";
	        lvideo = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/loop -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf --no-resume-playback --panscan=1' '*'";
	        playlist = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video/playlist/ -e m3u | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o '--no-resume-playback --panscan=1' '*'";
	        #playl = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video/playlist -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf' '*'"; # FIX

            # REMOVE: eza
            sl = "${pkgs.eza}/bin/eza --icons --group-directories-first";
	        ls = "${pkgs.eza}/bin/eza --icons --group-directories-first";
	        la = "${pkgs.eza}/bin/eza -a --icons --group-directories-first";
	        ll = "${pkgs.eza}/bin/eza --long --group-directories-first";
	        lla = "${pkgs.eza}/bin/eza -a --long --group-directories-first";
	        lg = "${pkgs.eza}/bin/eza --long --git --group-directories-first";

            # REMOVE: swww
            wall = "fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | sk | xargs swww img";
	        #wall = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | ${pkgs.skim}/bin/sk | xargs ${inputs.swww.packages.${pkgs.system}.swww}/bin/swww img";
	        #wallp = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | ${pkgs.skim}/bin/sk | tee >(xargs ${inputs.swww.packages.${pkgs.system}.swww}/bin/swww img) >(xargs ${pkgs.wallust}/bin/wallust run)"; 

            # REMOVE: jp テレビ?
            jp = "${pkgs.mpv}/bin/mpv --no-resume-playback https://iptv-org.github.io/iptv/countries/jp.m3u > /dev/null 2>&1 & disown";
        };
    };

    imports = [

        # TODO Fix Priority
        ./modules/mpd.nix

        # TODO Modules to reduce and delete
        # MODIFY AND REMOVE FROM HOME
	    #./modules/vscode
	    #./modules/xmonad.nix
	    ./modules/librewolf.nix
        #./modules/spotifyd.nix
        #./modules/swappy.nix
        #./modules/swayidle.nix
        ./modules/git.nix
        ./modules/mpv.nix

        # MOVE TO NIX
        #./modules/games.nix

        # EMPTY
        #./modules/uwsm.nix

        # -------------------------------------------------
        # Remember to first rebuild home manager with 
        # the specified cache then enable the dotfile .
        ./substituters.nix
        ./minimal.nix
        #./sec.nix

        # Hyprland
        ../config/hypr
        # Wezterm
        # Yazi

        # -------------- Package modules and other --------------

	    # System
        ./modules/fonts.nix
        ./modules/settings.nix
        ./modules/stylix.nix
        ./modules/xdg.nix

        # Package Sets # REDUCE
        ./modules/audio.nix
        ./modules/cli.nix
        ./modules/gui.nix

        # Shell
        ./modules/aliases.nix
        ./modules/bash.nix
        ./modules/plugins.nix
        ./modules/zsh.nix
    ];
}
