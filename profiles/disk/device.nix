{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.disk;
in {
    options.meta.disk = {
        ssd = mkEnableOption "Enable drivers and optimizations for SSD-type drives.";
        device = mkOption {
            type = nullOr str;
            default = null;
            description = "Specify device where to install NixOS.";
        };
    };

    config = {
        assertions = [
            {
                assertion = cfg.device == null;
                message = "You must specify a system device for disko.";
            }
        ];

        services.fstrim.enable = cfg.ssd;
        environment.systemPackages = mkIf cfg.ssd [
            pkgs.fio
        ];
    };
}
