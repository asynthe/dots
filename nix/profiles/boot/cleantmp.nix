{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.boot;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.boot.cleantmp = mkEnableOption "Clean /tmp on reboot.";
    
    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.cleantmp {
        boot.tmp = {
            cleanOnBoot = true;
            #useTmpfs = true;
            #tmpfsSize = "20%"; # default `"50%"`.
        };
    };
}
