{ config, pkgs, ... }: {

    # REMOVE: zsh config
    programs.zsh = {
        #sessionVariables.STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
        initExtra = ''
            eval "$(starship init zsh)"
        '';
    };

    home.packages = builtins.attrValues { inherit (pkgs) starship; };
    xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink ../starship.toml;
}
