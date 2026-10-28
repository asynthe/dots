{ config, ... }:
{
  # Python backend, databases, infra and editors.
  flake.modules.nixos.profile-dev = {
    imports = with config.flake.modules.nixos; [
      python
      javascript
      database
      database-gui
      postgres-local
      dbt
      infra
      vscodium
      web-dev
      work
      virtualisation
    ];
  };
}
