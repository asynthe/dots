{ config, lib, pkgs, ... }:
let
    cfg             = config.sys.modules.boot;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.boot = {
        enable = lib.mkEnableOption "systemd-boot";
        configurationLimit = lib.mkOption {
            type    = lib.types.int;
            default = 3;
            description = "Max generations shown in the boot menu";
        };
        timeout = lib.mkOption {
            type    = lib.types.nullOr lib.types.int;
            default = null;
            description = "Boot menu timeout in seconds, null to wait indefinitely";
        };

        lanzaboote.enable = lib.mkEnableOption "Lanzaboote secure boot (replaces systemd-boot)";
        silent = lib.mkEnableOption "Silent boot (suppress kernel/initrd output)";
    };

    config = lib.mkMerge [
        (lib.mkIf cfg.enable {
            boot.loader.efi.efiSysMountPoint            = "/efi";
            boot.loader.efi.canTouchEfiVariables         = true;
            boot.loader.systemd-boot.enable              = true;
            boot.loader.systemd-boot.configurationLimit  = cfg.configurationLimit;
            boot.loader.timeout                          = cfg.timeout;
        })

        (lib.mkIf cfg.silent {
            boot.consoleLogLevel = 0;
            boot.initrd.verbose = false;
            boot.kernelParams = [
                "splash"
                "quiet"
                "rd.systemd.show_status=false"
                "rd.udev.log_level=3"
                "udev.log_priority=3"
            ];
        })

        (lib.mkIf cfg.lanzaboote.enable {
            environment.systemPackages = with pkgs; [ sbctl e2fsprogs ];

            boot.lanzaboote = {
                enable                    = true;
                pkiBundle                 = "/var/lib/sbctl";
                autoGenerateKeys.enable   = true;
                autoEnrollKeys.enable     = true;
                autoEnrollKeys.autoReboot = true;
            };

            boot.loader.timeout                         = null;
            boot.loader.efi.efiSysMountPoint            = "/efi";
            boot.loader.efi.canTouchEfiVariables         = true;
            boot.loader.systemd-boot.enable              = lib.mkForce false;
            boot.loader.systemd-boot.configurationLimit  = 3;

            environment.persistence.${impermanenceCfg.folder}.directories =
                lib.mkIf impermanenceCfg.enable [ "/var/lib/sbctl" ];
        })
    ];
}
