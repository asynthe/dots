{ config, ... }: {

    programs.lf = {
        enable = true;
	    #cmdKeybindings = ;
	    #commands = ;
	    #settings = ;
	    #extraConfig = ;
    };

    # lf -> lfcd
    programs.zsh = {
        initExtra = ''
	      lfcd () {
            cd "$(command lf -print-last-dir "$@")"
	      } 
        '';
	    shellAliases = {
	        lf = "lfcd";
	    };
    };
}
