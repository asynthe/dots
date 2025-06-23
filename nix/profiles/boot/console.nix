{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.boot;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.boot.console = mkOption {
        type = bool;
        default = false;
        description = "Enable and set up a custom console configuration.";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.console {
        console = {
            earlySetup = true;
            font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
            packages = with pkgs; [ terminus_font ];
            keyMap = "us";
        };
    };
}
