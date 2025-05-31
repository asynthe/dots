{ config, lib, pkgs-stable, ... }:
let
    xfce_wallpaper_dir = "/home/${config.meta.system.user}/wallpaper";
    FetchWallpaperScript = pkgs-stable.writeScriptBin "xfce-random-wallpaper.sh" 
    ''
    #!${pkgs-stable.bash}/bin/bash
    
    WALLPAPER_DIR='${xfce_wallpaper_dir}'
    MONITOR_WORKSPACE='/backdrop/screen0/monitorVirtual-1/workspace0/last-image'
    FILES=($(${pkgs-stable.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.png \)))
    NUM_FILES=''${#FILES[@]}

    if [ "$NUM_FILES" -eq 0 ]; then
      exit 1
    fi

    RAND=$(( RANDOM % NUM_FILES ))
    RANDOM_WALLPAPER=''${FILES[$RAND]}
    ${pkgs-stable.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop -p "$MONITOR_WORKSPACE" -s "$RANDOM_WALLPAPER"
    '';

in {

    systemd.user.services.xfce-random-wallpaper = {
        description = "Set a random XFCE wallpaper";
        path = with pkgs-stable; [ bash findutils xfce.xfconf coreutils ];
        serviceConfig.Type = "oneshot";
        serviceConfig.ExecStart = "${RandomWallpaperScript}/bin/xfce-random-wallpaper.sh";
    };

    systemd.user.timers.xfce-random-wallpaper = {
        description = "Timer for xfce-random-wallpaper.service";
        partOf = [ "xfce-random-wallpaper.service" ];
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = "*:0/5";
    };
}
