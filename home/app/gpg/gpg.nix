{ config, pkgs, ... }: {

    # I got it running with the next commands.
    # `pkill gpg-agent` (If gpg-agent is running)
    # `gpg-agent --pinentry-program=/home/user/.nix-profile/bin/pinentry-curses --daemon`

    programs.gpg = {
        enable = true;
	    homedir = "${config.xdg.configHome}/gnupg";
    };

    home.packages = builtins.attrValues {
        inherit (pkgs)
	        pinentry-curses
	    ;
    };

    # This doesn't work and shows me error output at login.
    services.gpg-agent = {
        enable = true;
	    enableSshSupport = true;
	    pinentryPackage = pkgs.pinentry-curses;
    };
}
