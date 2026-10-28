{ config, ... }:
{
  # Network tooling, SOC and pentest kit, log forwarding.
  flake.modules.nixos.profile-security = {
    imports = with config.flake.modules.nixos; [
      net-tools
      soc-tools
      pentest
      wazuh-syslog
    ];
  };
}
