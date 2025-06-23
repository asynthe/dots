{ config, lib, ... }: 

  # Action after closing laptop lid.
  # https://unix.stackexchange.com/questions/257587/how-to-disable-suspend-on-close-laptop-lid-on-nixos

  # Options: (default "suspend")
  # - ignore
  # - poweroff
  # - reboot
  # - halt
  # - kexec
  # - suspend
  # - hibernate
  # - hybrid-sleep
  # - suspend-then-hibernate
  # - lock

  # Also
  #services.logind.extraConfig = "HandleLidSwitch=ignore";

with lib;
let

  cfg = config.thinkpad.lid_switch;

in {

  options.thinkpad.lid_switch.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Define action after closing laptop lid.";
  };

  config = mkIf cfg.enable {
    services.logind = {
      lidSwitch = "ignore";
      lidSwitchDocked = "ignore";
    };
  };
}
