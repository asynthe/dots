#!/usr/bin/env bash

mkdir -p ~/sync/dots
git clone https://github.com/asynthe/dots.git ~/sync/dots
# This should be ssh-agnostic
# This should be once the setup is finished

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Fonts
brew tap homebrew/cask-fonts # Add Cask-Fonts Formulae
brew install --cask \
	font-fira-code-nerd-font \
	font-iosevka-nerd-font \
	font-jetbrains-mono-nerd-font \
	font-meslo-lg-nerd-font \
	font-mplus-nerd-font \
	font-noto-nerd-font

# Terminal Setup
brew install jstkdng/programs/ueberzugpp # Ueberzugpp

# Symbolic links
