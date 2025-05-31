{ config, lib, ... }: {

    # Action after closing laptop lid.
    # https://unix.stackexchange.com/questions/257587/how-to-disable-suspend-on-close-laptop-lid-on-nixos

    # Options: (default "suspend")
    # ignore, poweroff, reboot, halt, kexec, suspend
    # hibernate, hybrid-sleep, suspend-then-hibernate, lock

    services.logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
    };

    # Also
    #services.logind.extraConfig = "HandleLidSwitch=ignore";
}
