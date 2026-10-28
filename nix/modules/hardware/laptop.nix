_: {
  flake.modules.nixos.laptop =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.acpi ];

      powerManagement.enable = true;
      services.thermald.enable = true;
      services.auto-cpufreq.enable = false;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;

      sys.persist.directories = [ "/var/lib/upower" ];

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "suspend";
      };
    };
}
