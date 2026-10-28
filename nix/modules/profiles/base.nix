{ config, ... }:
{
  # Every machine: nix, users, secrets, boot, network, shell tooling.
  flake.modules.nixos.profile-base = {
    imports = with config.flake.modules.nixos; [
      core
      cli
      auth
      gpg
      pass
      sops
      boot
      boot-silent
      network
      ssh
      git
      neovim
      nh
      atuin
    ];
  };
}
