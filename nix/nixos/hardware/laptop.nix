{ ... }:
{
    flake.modules.nixos.laptop = { config, lib, pkgs, ... }: {
        environment.systemPackages = [ pkgs.acpi ];

        powerManagement.enable = true;
        services.thermald.enable = true;
        services.auto-cpufreq.enable = false;

        # Battery, lid and AC state over dbus. Every shell's battery widget
        # reads it; without it they show nothing on a machine that has a battery.
        services.upower.enable = true;
        # The performance/balanced/power-saver switch those widgets write to.
        # Mutually exclusive with tlp and auto-cpufreq -- neither is enabled here.
        services.power-profiles-daemon.enable = true;

        # Charge history and the calibrated capacity estimate, both of which
        # take days to rebuild from scratch.
        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/upower" ];

        services.logind.settings.Login = {
            HandleLidSwitch = "suspend";              # on battery
            HandleLidSwitchDocked = "ignore";         # docked (external display)
            HandleLidSwitchExternalPower = "suspend"; # plugged in, no external display
        };
    };

    flake.modules.nixos.fingerprint = { config, lib, ... }: {
        services.fprintd.enable = true;
        security.pam.services = {
            login.fprintAuth = true;
            sudo.fprintAuth = true;
        };

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/fprint" ];
    };

    flake.modules.nixos.firmware = { config, lib, ... }: {
        services.fwupd.enable = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/fwupd" ];
    };
}
