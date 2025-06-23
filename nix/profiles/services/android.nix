{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.android;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.android.enable = mkEnableOption "Enable and set up adb and other Android related tools.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {
        
        programs.adb.enable = true;
        users.users.${config.meta.system.user}.extraGroups = [ "adbusers" ];
        #virtualisation.waydroid.enable = true;
        environment.systemPackages = with pkgs; [
            jmtpfs
            scrcpy
        ];
    };
}
