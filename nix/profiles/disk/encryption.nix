{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.disk.encryption;
in {
    # REMEMBER TO ADD THE DEVICE_NAME VARIABLE
    # TO ASCII (MESSAGE) AND DISKO CONFIGURATION

    options.meta.disk.encryption = {
        enable = mkEnableOption "Enable LUKS encryption.";

        device_name = mkOption {
            type = nullOr str;
            default = null;
            description = "Name of the /dev/mapper device.";
        };

        message = mkOption {
            type = nullOr str;
            default = null;
            description = "Enable a message when using LUKS encryption.";
        };
    };

    imports = [
        ./luks_ascii/cat.nix
        ./luks_ascii/dice.nix
    ];

    config = mkIf cfg.enable {

        # ADD assertion once everything is configured.
        #assertions = [
            #{
                #assertion = cfg.device_name != null;
                #message = "Please specify a device name for meta.disk.encryption.device_name.";
            #}
        #];
    };
}
