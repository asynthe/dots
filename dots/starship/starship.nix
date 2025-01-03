{ config, pkgs, ... }: {

    # Set up the starship location variable in bash / zsh / nu
    # to ~/.config/starship/starship.toml
    #shellVariables # Add STARSHIP_CONFIG=$HOME/.config/wayfire/wayfire.ini

    home.packages = builtins.attrValues { inherit (pkgs) starship; };
    programs.zsh = {
        #sessionVariables.STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
        initExtra = ''
            eval "$(starship init zsh)"
        '';
    };

    xdg.configFile = {
        "starship.toml".source = config.lib.file.mkOutOfStoreSymlink ../starship.toml;
    };

    #programs.starship = {
        #enable = config.programs.zsh.enable;
	    #enableZshIntegration = config.programs.zsh.enable;
	    #settings = {

            # Get editor completions based on the config schem
	        #"$schema" = "https://starship.rs/config-schema.json"; 

            #right_format = "」にゃ~(white)";
            #continuation_prompt = "▶▶";
	        #add_newline = true; # ?
	        #line_break.disabled = true; # Makes prompt a single line.
	        #command_timeout = 20000;

            #username = {
	        #disabled = false;
		    #format = "[$user ](#0099ff)";
		    #show_always = true;
                #style_user = "bg:#9A348E"; # ?
                #style_root = "bg:#9A348E"; # ?
            #};

          #hostname = {
	      #    disabled = false;
		  #    ssh_only = false;
		  #    format = "on [$hostname](#ff3399) ";
		  #    trim_at = ".";
	      #};
          #
	      #directory = {
	      #    disabled = false;
		  #    format = "in [$path]($style) ";
		  #    truncation_length = 2;
		  #    truncation_symbol = ".../";
		  #    read_only = "";
	      #    substitutions = {
		  #        "~"="󰋜 ";
          #        ".config"=" ";
          #        "sync"=" ";
          #        "games" = " ";
          #        "music" = " ";
          #        "Desktop" = " ";
          #        "Downloads" = "󰇚 ";
		  #    };
	      #};
          #
          #cmd_duration = {
	      #    disabled = true;
		  #    show_milliseconds = false;
		  #    style = "bold italic red";
	      #};
          #
	      #character = {
		  #    success_symbol = "[「](white)";
          #    #success_symbol = "[>ω<〜☆](bold green)";
          #
          #    error_symbol = "[ >_< [「]()](bold red)";
          #    #error_symbol = "[ >_< 「](bold red)";
          #    #error_symbol = "[ノ_<](bold red)";
          #
		  #    vimcmd_symbol = "[「](white)";
		  #    vimcmd_replace_symbol = "[「](white)";
		  #    vimcmd_replace_one_symbol = "[「](white)";
		  #    vimcmd_visual_symbol = "[「](white)";
	      #};
          #
	      ## Disable the package module, hiding it from the prompt completely
          #package = {
	      #    disabled = false;
		  #    symbol = " ";
          #};
          #
          ## Disable show `container` in prompt
          #container.disabled = true;
          #
	      ## Symbols preset - nerd fonts
	      #aws.symbol = "  ";
	      #buf.symbol = " ";
          #c.symbol = " ";
	      #conda.symbol = " ";
	      #dart.symbol = " ";
	      #docker_context.symbol = " ";
	      #elixir.symbol = " ";
	      #elm.symbol = " ";
	      #golang.symbol = " ";
	      #haskell.symbol = " ";
	      #hg_branch.symbol = " ";
	      #java.symbol = " ";
	      #julia.symbol = " ";
	      #lua.symbol = " ";
	      #memory_usage.symbol = " ";
	      ##meson.symbol = "喝 ";
	      ##nim.symbol = " ";
	      #nix_shell.symbol = " ";
	      #nodejs.symbol = " ";
	      #python.symbol = " ";
	      #rlang.symbol = "ﳒ ";
	      #ruby.symbol = " ";
	      #rust.symbol = " ";
	      #scala.symbol = " ";
	      #spack.symbol = "🅢 ";
          #
	      ## git
          ##git_branch = {
          #    #symbol = " ";
          #    #[git_status] = {
          #        #style = "167"
          #        #conflicted = "🏳"
          #        #ahead = "🏎💨"
          #        #behind = "😰"
          #        #diverged = "😵"
          #        #up_to_date = "✓"
          #        #untracked = "🤷‍"
          #        #stashed = "📦"
          #        #modified = "📝"
          #        #staged = '[++\($count\)](green)'
          #        #renamed = "👅"
          #        #deleted = "🗑"
	      #    #};
	      ##};
	    #};
    #};
}
