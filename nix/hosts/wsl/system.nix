{ config, lib, pkgs, ... }: {

  networking.hostName = "wsl"; # check wsl.wslConf.network.hostname
  system.stateVersion = "24.11"; # Did you read the comment?
  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "meow" ];
  };

  wsl = {
    enable = true;
    #defaultUser = "meow";
    #startMenuLaunchers = true;
    #wslConf = {
      #automount.root = "/home/meow/win"; # TODO Where to mount windows drive
      #boot.command = "";
    #};
  };

  # Services
  imports = [
    ../../modules/ollama.nix
  ];
}
