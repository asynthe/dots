{
    imports = [
        ./system.nix

        # Modules
	    ../../modules/simple/gpg.nix
        ../../modules/simple/ime.nix
        #../../modules/simple/ollama.nix

        # Pkgs
        ../../pkgs/set/wsl.nix
        ../../pkgs/set/fonts.nix
    ];
}
