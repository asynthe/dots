{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.clamav;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.clamav.enable = mkEnableOption "Enable and set up ClamAV.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {
        services.clamav = {
            daemon = {
                enable = true;
                #settings = ;
            };
            updater = {
                enable = true;
                #interval = ""; # default `hourly`.
                #frequency = 12; # default `12`.
                #settings = ;
            };
        };
    };
}
