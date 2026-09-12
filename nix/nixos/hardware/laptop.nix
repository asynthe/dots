{ ... }:
{
    flake.modules.nixos.laptop = { config, lib, pkgs, ... }: {
        environment.systemPackages = [ pkgs.acpi ];

        powerManagement.enable = true;
        services.thermald.enable = true;
        services.auto-cpufreq.enable = false;

        # Battery, lid and AC state over dbus; every shell's battery widget reads it.
        services.upower.enable = true;
        # The power-profile switch those widgets write to; excludes tlp and auto-cpufreq.
        services.power-profiles-daemon.enable = true;

        # Charge history and capacity estimate; both take days to rebuild.
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
