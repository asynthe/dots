{ config, pkgs, lib, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) direnv nix-direnv; };
    xdg.configFile."direnv/direnv.toml".source = config.lib.file.mkOutOfStoreSymlink ./direnv.toml;

    # Set up in bashrc, zshrc and nushell then comment out here.
    programs.zsh = lib.mkIf config.programs.direnv.enableZshIntegration {
        initExtra = ''
	      eval "$(direnv hook zsh)"
	      export DIRENV_LOG_FORMAT=""
	    '';
    };
}
