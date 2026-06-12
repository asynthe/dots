{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.android;
in {
    options.sys.modules.android = {
        enable = lib.mkEnableOption "Android";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.waydroid.enable = true;
        #services.gvfs.enable = true;
        users.users.meow.extraGroups = [ "kvm" "adbusers" ];
        environment.systemPackages = with pkgs; [
            android-studio-full
            android-tools
            jmtpfs
            scrcpy
        ];
    };
}
