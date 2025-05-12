{ config, user, ... }: {

    programs.zsh = {
        enable = true;
	    defaultKeymap = "viins"; # `emacs`, `vicmd`, `viins`.

	    # No comments...
	    dotDir = ".config/zsh";
        #dotDir = "${user}";
        #dotDir = "/home/${user}/.config/zsh";
        #dotDir = "${config.xdg.configHome}/zsh";

        # Configuration
        autocd = true;
        history = {
            size = 10000;
            path = "${config.xdg.configHome}/zsh/zsh_history";
        };

	    # Variables
	    sessionVariables = {
	        #TERM = "xterm-256color"; # ?
	        EDITOR = "nvim";
	        FILE = "lf";
    	};
    };

    # App integrations
    programs = {
        fzf.enableZshIntegration = config.programs.zsh.enable;
        skim.enableZshIntegration = config.programs.zsh.enable;
        broot.enableZshIntegration = config.programs.zsh.enable;
        direnv.enableZshIntegration = config.programs.zsh.enable;
        #pyenv.enableZshIntegration = config.programs.zsh.enable;
    };
}
