{ config, pkgs, lib, ... }: {

    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
        mpv = "mpv --profile=norm";
	    cl = "mpv --no-resume-playback https://iptv-org.github.io/iptv/countries/cl.m3u";
    };
}
