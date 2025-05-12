{ pkgs, ... }: {
    programs.zsh.shellAliases = {

        # General
	    py = "python3";
        disk = "(df -h | head -n 1; df -h | grep nvme)";
        m = "ncmpcpp";
        n = "nvim";
        off = "poweroff";
        p = "ping";
        rm = "rm -i";
        t = "${pkgs.tty-clock}/bin/tty-clock -ScB";
        v = "${pkgs.alsa-utils}/bin/alsamixer";
        vv = "${pkgs.pulsemixer}/bin/pulsemixer";

        # Git
        ga = "git add -A";

	    # Tools
	    bt = "${pkgs.bluetuith}/bin/bluetuith";
	    yt = "${pkgs.yt-dlp}/bin/yt-dlp -f  'bv[ext=mp4]+ba[ext=m4a]' --merge-output-format mp4";
	    yt-mp3 = "${pkgs.yt-dlp}/bin/yt-dlp -f 'ba' -x --audio-format mp3";

	    # Random
	    rickroll = "${pkgs.curl}/bin/curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master.roll.sh | ${pkgs.bash}/bin/bash";

	    # Nix
	    #update = "nix flake update '${config.home.homeDirectory}/flake' && home-manager switch --flake '${config.home.homeDirectory}/flake#meow' && sudo nixos-rebuild switch --flake '${config.home.homeDirectory}/flake#thinkpad'";
	    #upgrade = "sudo nixos-rebuild switch --flake ${config.xdg.configHome}/flake#thinkpad"; 
	    #upgrade-home = "home-manager switch --flake ${config.xdg.configHome}/flake#meow"; 
	    #gc = "sudo nix-collect-garbage -d";
	    #gc-home = "nix-env --delete-generations 7d && nix-store --gc";
    };
}
