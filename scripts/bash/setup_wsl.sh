#!/usr/bin/env bash

# TODO: Make so it crashes whenever there's an error
# TODO: Where to add the `2>&1 /dev/null`

# TODO: Insteresting line, may help run nixos-rebuild without sudo
sudo visudo
meow ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild

# Script / Note to configure starting NixOS-WSL.

sudo useradd -m -G wheel -s /bin/bash meow
sudo passwd
sudo passwd meow

# in `/etc/nixos/configuration.nix`
sudo nano /etc/nixos/configuration.nix

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "meow" ];
  };

# TODO Add meow to allowed users list (?)

sudo nixos-rebuild switch

##### WSL CONFIGURATION #####

# Change user to which start wsl with
# in /etc/wsl.conf

[user]
default=meow
# TODO How do I do this in nix (?)
# I think it's not recommended

# Change directory to which start wsl in
# in ~/.zshrc
cd ~

# Installing the flake
echo '##### INSTALLING ASYNTHE SYSTEM'

# ENV VARIABLES
FLAKE = '~/dots'

# Change username
# Keep regular nix with regular dotfiles

### WINDOWS NOTES
###
### Disable rounded corners
### https://github.com/valinet/Win11DisableRoundedCorners
###

# Cava working on Windows WSL
# https://github.com/quantum5/winscap
#
# Make the next be automatically started !!!
# $ mkfifo /tmp/cava.fifo & disown # Keep pid into account, can i catch it someway?
# $ /mnt/c/path/to/winscap.exe 2 48000 16 > /tmp/cava.fifo
#
# -> TODO: Systemd user service for this?

