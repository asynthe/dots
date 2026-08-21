{ ... }:
{
    flake.modules.nixos.laptop = { ... }: {
        powerManagement.enable = true;
        services.thermald.enable = true;
        services.auto-cpufreq.enable = false;
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
