{ inputs, ... }:
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

    flake.modules.nixos.lanzaboote = { config, lib, pkgs, ... }: {
        imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

        environment.systemPackages = with pkgs; [ sbctl e2fsprogs ];

        boot.lanzaboote = {
            enable                    = true;
            pkiBundle                 = "/var/lib/sbctl";
            autoGenerateKeys.enable   = true;
            autoEnrollKeys.enable     = true;
            autoEnrollKeys.autoReboot = true;
        };

        boot.loader.timeout                          = 3;
        boot.loader.efi.efiSysMountPoint             = "/efi";
        boot.loader.efi.canTouchEfiVariables         = true;
        boot.loader.systemd-boot.enable              = lib.mkForce false;
        boot.loader.systemd-boot.configurationLimit  = 3;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/sbctl" ];
    };
}
