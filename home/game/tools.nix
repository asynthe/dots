{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
	        mangohud
	        lutris
	    ;
    };
}
