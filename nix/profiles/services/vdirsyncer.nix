{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.vdirsyncer;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.vdirsyncer.enable = mkEnableOption "Enable and set up vdirsyncer.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        environment.systemPackages = with pkgs; [ khal vdirsyncer ];

        systemd.user.services.vdirsyncer-sync = {
            description = "vdirsyncer sync + calendar backup";
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.bash}/bin/bash %h/media/backup/calendar/main.sh";
            };
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
        };

        systemd.user.timers.vdirsyncer-sync = {
            description = "Run vdirsyncer sync every 2 minutes";
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "30s";
                OnUnitActiveSec = "2m";
                Persistent = true;
            };
        };
    };
}
