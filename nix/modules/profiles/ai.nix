{ config, ... }:
{
  # Coding agents and the Hermes service.
  flake.modules.nixos.profile-ai = {
    imports = with config.flake.modules.nixos; [
      codex
      claude-code
      opencode
      hermes
    ];
  };
}
