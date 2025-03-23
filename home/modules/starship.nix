{ config, pkgs, ... }: {

    # REMOVE: zsh config
    programs.zsh = {
        #sessionVariables.STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
        initExtra = ''
            eval "$(starship init zsh)"
        '';
    };
}
