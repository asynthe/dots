{ ... }:
{
    flake.modules.nixos.laptop = { config, lib, pkgs, ... }: {
        environment.systemPackages = [ pkgs.acpi ];

        powerManagement.enable = true;
        services.thermald.enable = true;
        services.auto-cpufreq.enable = false;

        services.upower.enable = true;
        services.power-profiles-daemon.enable = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/upower" ];

        services.logind.settings.Login = {
            HandleLidSwitch = "suspend";
            HandleLidSwitchDocked = "ignore";
            HandleLidSwitchExternalPower = "suspend";
        };
    };
}
