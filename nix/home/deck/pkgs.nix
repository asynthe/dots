{ pkgs, nixglPkgs, ... }:

{
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [

    	# GUI
        ghostty #ghostty-bin
	alacritty

	# Graphics/OpenGL wrapper (needed for GUI apps on non-NixOS systems)
	# Run apps with: nixGLDefault ghostty
	nixglPkgs.nixGLDefault

	# Tools
	rustup
	terraform
	nodejs
        helix
        neovim
        tectonic # LaTeX Engine
	ollama

	# Clipboard
	xclip
	xdg-utils

	# Archive
	p7zip
	rar
	unar
	zip unzip

	# Fonts
	corefonts
	dejavu_fonts
	et-book # https://edwardtufte.github.io/et-book/
	font-awesome
	liberation_ttf
	office-code-pro
	source-sans-pro
	noto-fonts
	noto-fonts-cjk-sans
	noto-fonts-color-emoji
	nerd-fonts.fira-code
	nerd-fonts.iosevka-term
	nerd-fonts.iosevka-term-slab
	nerd-fonts.jetbrains-mono
	nerd-fonts.meslo-lg
	nerd-fonts.mononoki
	nerd-fonts.overpass
	nerd-fonts.sauce-code-pro
	nerd-fonts.ubuntu-sans
	nerd-fonts.zed-mono
    ];
}
