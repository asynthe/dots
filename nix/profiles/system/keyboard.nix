{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.system;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.system = {
        keyboard = mkEnableOption "Enable firmware and programs for keyboards and RGB.";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.keyboard {

        # QMK
        hardware.keyboard.qmk.enable = true;
        #environment.systemPackages = with pkgs; [ qmk ];

        # OpenRGB
        services.hardware.openrgb = {
            enable = true;
            motherboard = "intel";
            #server.port = 6742;
            #package = pkgs.openrgb-with-plugins'
        };
    };
}
