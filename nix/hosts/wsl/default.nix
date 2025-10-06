{
    imports = [
        ./system.nix

        # Modules
	    ../../modules/simple/gpg.nix
        ../../modules/simple/neovim.nix

        # Pkgs
        ../../pkgs/set/minimal.nix
        ../../pkgs/set/fonts.nix
        ../../pkgs/set/fonts_jp.nix
    ];
}
