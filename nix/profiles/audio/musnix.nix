{ config, lib, ... }: 
with lib; with types;
let
    cfg = config.meta.audio.musnix;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.audio.musnix.enable = mkEnableOption "Enable audio configuration. (Musnix)";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {
        musnix = {
            enable = true;
            #alsaSeq.enable = true;
            #ffado.enable = true; # Use the Free FireWire Audio Drivers (FFADO).
            #soundcardPciId = "00:1b.0"; # The PCI ID of the primary soundcard.

            # Kernel Options (can be set up without musnix.enable)
            #kernel = {
                #realtime = true; # False by default.
                #packages = [ pkgs.linuxPackages_latest_rt ];

                # rtirq Options (can be set up without setting musnix.enable)
                # `musnix.kernel.realtime` must be set to true
                #rtirq.enable = false;

                # Other
                #das_watchdog.enable = true; # True if musnix.kernel.realtime = true.
            #};
        };
    };
}
