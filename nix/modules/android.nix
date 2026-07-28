{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.android;
in {
    options.sys.modules.android = {
        enable = lib.mkEnableOption "Android";
    };

    config = lib.mkIf cfg.enable {
        #programs.nix-ld.enable = true;
        #programs.nix-ld.libraries = [ pkgs.libGL pkgs.glib ];

        #virtualisation.waydroid.enable = true;
        #services.gvfs.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "kvm" "adbusers" ];
        environment.systemPackages = with pkgs; [
            #androidsdk
            android-tools
            #android-studio
            #jmtpfs
            scrcpy
        ];
    };
}
