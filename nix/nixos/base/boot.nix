{ ... }:
{
    flake.modules.nixos.boot = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.efibootmgr ];

        boot.loader.efi.efiSysMountPoint             = "/efi";
        boot.loader.efi.canTouchEfiVariables         = true;
        boot.loader.systemd-boot.enable              = true;
        boot.loader.systemd-boot.configurationLimit  = 3;
        boot.loader.timeout                          = 3;
    };

    flake.modules.nixos.boot-silent = { ... }: {
        boot.consoleLogLevel = 0;
        boot.initrd.verbose = false;
        boot.kernelParams = [
            "splash"
            "quiet"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
        ];
    };
}
