{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.laptop;
in {
    options.sys.modules.laptop = {
        enable = lib.mkEnableOption "Laptop";
    };

    config = lib.mkIf cfg.enable {
        powerManagement.enable = true;
        services.thermald.enable = true;
        services.auto-cpufreq.enable = true;

        # "ignore", "poweroff", "reboot", "halt", "kexec",
        # "suspend", "hibernate", "hybrid-sleep"
        services.logind.settings.Login = {
            HandleLidSwitch = "suspend";                # on battery
            HandleLidSwitchDocked = "ignore";           # when docked (external display connected)
            HandleLidSwitchExternalPower = "suspend";   # plugged in, no external display
        };
    };
}
