{ config, pkgs, ... }: {

    programs.eza = {
        enable = true;
        enableBashIntegration = config.programs.bash.enable;
        enableNushellIntegration = config.programs.nushell.enable;
        enableZshIntegration = config.programs.zsh.enable;
    };

    # Set in bash / zsh / nu 
    # source this aliases?
    programs.zsh.shellAliases = {
        sl = "${pkgs.eza}/bin/eza --icons --group-directories-first";
	    ls = "${pkgs.eza}/bin/eza --icons --group-directories-first";
	    la = "${pkgs.eza}/bin/eza -a --icons --group-directories-first";
	    ll = "${pkgs.eza}/bin/eza --long --group-directories-first";
	    lla = "${pkgs.eza}/bin/eza -a --long --group-directories-first";
	    lg = "${pkgs.eza}/bin/eza --long --git --group-directories-first";
    };
}
