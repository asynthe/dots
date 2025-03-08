{ config, lib, pkgs, ... }: {

    xdg.configFile."zathura/zathurarc".source = config.lib.file.mkOutOfStoreSymlink ./zathurarc;
    home.packages = builtins.attrValues { inherit (pkgs) zathura; };

    #stylix.targets.zathura.enable = lib.mkForce false;
    #programs.zathura.enable = true;
    # Move to bash / zsh / nushell and comment out here
    programs.zsh = lib.mkIf config.programs.zsh.enable {
        sessionVariables.READER = "zathura";
        shellAliases = {
	        pdf = "zathura";

            # TODO Redirect output to /dev/null (?)
	        book = "${pkgs.fd}/bin/fd . ~/sync/archive/book/reading --type f -e 'pdf' -e 'epub' | ${pkgs.skim}/bin/sk | xargs zathura & disown";
        };
    };
}
