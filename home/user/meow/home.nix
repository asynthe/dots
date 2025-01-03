{ config, pkgs, user, ... }: {

    programs.home-manager.enable = true;

    home = {
        username = user;
        homeDirectory = "/home/${user}";
        stateVersion = "24.05";
        sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    };

    # Hide "last login" message on new terminal.
    home.file.".hushlogin".text = "";

    # Testing 
    home.packages = [ pkgs.monero-gui ];
}
