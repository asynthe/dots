{ config, pkgs, lib, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) mpvpaper; };
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
	    video = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf --no-resume-playback --panscan=1' '*'";
	    lvideo = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/loop -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf --no-resume-playback --panscan=1' '*'";
	    playlist = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video/playlist/ -e m3u | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o '--no-resume-playback --panscan=1' '*'";
	    #playl = "${pkgs.fd}/bin/fd . ${config.home.homeDirectory}/sync/archive/wallpaper/video/playlist -e mp4 | ${pkgs.skim}/bin/sk | xargs ${pkgs.mpvpaper}/bin/mpvpaper -v -p -o 'loop-file=inf' '*'"; # FIX
    };
}
