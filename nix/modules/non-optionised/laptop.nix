{
    # Closing lid
    # "ignore", "poweroff", "reboot", "halt", "kexec", 
    # "suspend", "hibernate", "hybrid-sleep"
    services.logind.settings.Login = {
        HandleLidSwitch = "ignore";                 # on battery

        HandleLidSwitchDocked = "ignore";           # when docked
        # TODO Test, this should not suspend
        # when there is more than one monitor plugged

        HandleLidSwitchExternalPower = "ignore";    # plugged in 
    };

    powerManagement.enable = true;
    services.thermald.enable = true;
    services.auto-cpufreq.enable = true;
}
