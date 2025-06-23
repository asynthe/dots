# TODO Make `output` path an custom option.

{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.services.locate;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.locate.enable = mkEnableOption "Enable and set up Locate daemon. (plocate)";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.locate = {
            enable = true;
            package = pkgs.plocate;
            interval = "hourly"; # updates by default at 2:15 AM every day.
            #localuser = null;
            #output = "/var/cache/locatedb" # The database file to build.
        };
    };
}
