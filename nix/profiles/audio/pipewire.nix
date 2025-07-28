{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.audio.pipewire;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.audio.pipewire = {
        enable = mkEnableOption "Enable Pipewire audio setup and configuration.";
        low-latency = mkEnableOption "Enable low latency configuration.";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        # Pipewire audio configuration.
        # See more at https://wiki.nixos.org/wiki/Pipewire
        # See more at https://wiki.nixos.org/wiki/PulseAudio

        users.users.${config.meta.system.user}.extraGroups = [ "audio" ];
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            audio.enable = true; # Use as primary sound server.
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true; # Use JACK applications.
            wireplumber.enable = true;
        };

        services.pipewire = {
            # Low-latency setup
            extraConfig.pipewire = {
                "92-low-latency" = mkIf cfg.low-latency {
                    context.properties = {
                        default.clock.rate = 48000;
                        default.clock.quantum = 32;
                        default.clock.min-quantum = 32;
                        default.clock.max-quantum = 32;
                    };
                };
            };

            # TODO If laptop
            wireplumber.extraConfig = {
                "10-disable-hdmi-outputs"."monitor.alsa.rules" = [{
                    matches = [{ "node.name" = "~.*HDMI[123]__sink"; }];
                    actions.update-props = { "node.disabled" = true; };
                }];
            };
        };
    };
}
