{ ... }:
{
    flake.modules.nixos.bluetooth = { config, lib, pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bluetuith
            bluez-tools
        ];

        services.blueman.enable        = true;
        hardware.bluetooth.enable      = true;
        hardware.bluetooth.powerOnBoot = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/bluetooth" ];

        # TODO hardware.bluetooth.settings to disable hands-free mode, test with the nothing earphones
    };
}
