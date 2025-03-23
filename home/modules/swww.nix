{ config, inputs, lib, pkgs, user, ... }: 
with lib;
let
    #wallpaper_type = "dark";
    wallpaper_dir = /home/${user}/sync/yuugen/dots/wallpaper/light;
    wallpaper_script = pkgs.writeShellApplication {
        name = "swww-random-wallpaper";
        #runtimeInputs = [ inputs.swww.packages.${pkgs.system}.swww ];
        runtimeInputs = [ pkgs.swww ];
        text = ''
          export SWWW_TRANSITION=simple
          export SWWW_TRANSITION_STEP=2
          export SWWW_TRANSITION_DURATION=3
          export SWWW_TRANSITION_FPS=60
          #export SWWW_TRANSITION_FPS=165
          #export SWWW_TRANSITION_ANGLE=90
          #export SWWW_TRANSITION_POS=left
          #export SWWW_TRANSITION_BEZIER=.07,.56,1,.25

          # This controls (in seconds) when to switch to the next image
          INTERVAL=900 # 15 Minutes
          DIRECTORY=${wallpaper_dir}
          FREEZE_FILE=$HOME/.cache/sww-random-wallpaper-freeze

          while true; do
            if [ -f "$FREEZE_FILE" ]; then
              sleep $INTERVAL
              continue
            fi

            find "$DIRECTORY" -type f | while read -r img; do
              echo "$((RANDOM % 1000)):$img"
            done | sort -n | cut -d':' -f2- | while read -r img; do
              swww img "$img"
              sleep $INTERVAL
            done
          done
        '';
    };
in {

    home.packages = [
        inputs.swww.packages.${pkgs.system}.swww
        #pkgs.swww
        pkgs.waypaper # Kinda like Nitrogen.
        #pkgs.fd
        #pkgs.skim
        #pkgs.xargs
    ];

    #wayland.windowManager.hyprland.settings.exec-once = [
        #"sleep 1 && swww-daemon &"
        #"sleep 1 && ${pkgs.swww}/bin/swww-daemon &"
        #"sleep 1 && ${wallpaper_script}/bin/sww-random-wallpaper &"
    #];

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
        wall = "fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | sk | xargs swww img";
	    #wall = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | ${pkgs.skim}/bin/sk | xargs ${inputs.swww.packages.${pkgs.system}.swww}/bin/swww img";
	    #wallp = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/img -e jpg -e png | ${pkgs.skim}/bin/sk | tee >(xargs ${inputs.swww.packages.${pkgs.system}.swww}/bin/swww img) >(xargs ${pkgs.wallust}/bin/wallust run)"; 
    };
}
