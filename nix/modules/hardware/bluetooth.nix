_: {
  flake.modules.nixos.bluetooth =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        bluetuith
        bluez-tools
      ];

      services.blueman.enable = true;
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      sys.persist.directories = [ "/var/lib/bluetooth" ];

      # TODO hardware.bluetooth.settings to disable hands-free mode, test with the nothing earphones
    };
}
