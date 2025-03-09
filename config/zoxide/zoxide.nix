{ config, ... }: {

    # cd -> zoxide
    programs.zoxide = {
        enable = true;
	    enableBashIntegration = config.programs.bash.enable;
	    enableNushellIntegration = config.programs.nushell.enable;
	    enableZshIntegration = config.programs.zsh.enable;
	    #options = [ ];
    };

    programs.zsh.initExtra = '' 
      eval "$(zoxide init --cmd cd zsh)"
    '';
}
