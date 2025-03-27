{ config, pkgs, ... }: 

let
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
in {
    services.swayidle = {
	enable = true;
	#timeouts = [
	    #{
		    #timeout = 120;
		    #command = "${hyprctl} dispatch dpms off";
		    #resumeCommand = "${hyprctl} dispatch dpms on";
	    #}
	    #];
    };
}
