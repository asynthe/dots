{
    imports = [
        ./system.nix

        # Modules
	    ../../modules/simple/gpg.nix
        ../../modules/simple/neovim.nix

        # Pkgs
        ../../pkgs/set/minimal_wsl.nix
        ../../pkgs/set/fonts.nix
        ../../pkgs/set/fonts_jp.nix
    ];
}
