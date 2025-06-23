{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.gaming;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.gaming.controller = mkEnableOption "Enable Xbox controller.";
    
    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.controller {
        hardware = {
            xone.enable = true; # Driver.
	        xpadneo.enable = true; # Bluetooth driver.
        };
    };
}
