{ config, pkgs, ... }: {

  imports = [
    ./test/sshfs_automount.nix
    ./test/outside.nix

    ./hardware.nix
    ../modules.nix
  ];

  networking.hostName = "thinknya"; # Set up as "${hostname}" if you've defined a custom hostname.

  thinkpad = {
    user.enable = true; # Personal user.
    networkmanager.enable = true;
    lid_switch.enable = true; # Custom configuration for the laptop lid action.
    t480.fingerprint.enable = true;
    server.automount.systemd = true;
  };

  # List of packages I want to have on any computer.
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      alacritty kitty # Always good to have some extra terminals.
      wget curl
      git # Git must be installed before flakes.
      cachix
      tmux
      ungoogled-chromium
      pavucontrol
      neovim
      ;
  };

}
