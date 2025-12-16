{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.radicale;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.radicale.enable = mkEnableOption "Enable and set up the Radiale CalDAV.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {
        
        #environment.systemPackages = with pkgs; [ radicale ];
        services.radicale = {
            enable = true;
            settings = {
                auth.type = "none";
            };
        };
    };
}
