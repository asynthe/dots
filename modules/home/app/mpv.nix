{ config, pkgs, ... }: {

    programs.mpv = {
        enable = true;
	scripts = with pkgs.mpvScripts; [
	    mpris
	    thumbnail
	    thumbfast
	    visualizer
	];
	config = {
	    volume-max = "100";
	    save-position-on-quit = true;
	    hls-bitrate = "max";

	    osc = true;
	    force-window = true;
	    fullscreen = "no";

	    #cache-default = 4000000;
	    screenshot-directory = "~/Downloads/mpv_screenshots/";
	    screenshot-template = "%F_$03n";
	    #"extension.flac" = "";
	    #"extension.mkv" = "";
	    #"extension.gif" = "";

	    #profile = "gpu-hq";
	};
	profiles = {
	    norm = {
	        profile-desc = "Normalize audio volume";
		af = "lavfi=[loudnorm=I=-16:TP=-3:LRA=4]";
	    };
	};
	bindings = {
	    h = "seek -5";
	    j = "add volume -2";
	    k = "add volume 2";
	    l = "seek 5";
	};
    };
}
