{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.audio.pipewire;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.audio.pipewire = {
        enable = mkEnableOption "Enable Pipewire audio setup and configuration.";
        lowlatency = mkOption {
            type = types.bool;
            default = false;
            description = "Enable low latency configuration.";
        };
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        # Pipewire audio configuration.
        # See more at https://wiki.nixos.org/wiki/Pipewire
        # See more at https://wiki.nixos.org/wiki/PulseAudio

        users.users.${config.meta.system.user}.extraGroups = [ "audio" ];
        security.rtkit.enable = true;

        # Needed by Pipewire.
        #environment.systemPackages = builtins.attrValues { inherit (pkgs) pulseaudio; }; # pulsemixer?
        #hardware.pulseaudio.enable = false;
        #hardware.pulseaudio.support32Bit = true; # Gaming fix.

        # Pipewirez
        services.pipewire = {
            enable = true;
            audio.enable = true; # Use as primary sound server.
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true; # Use JACK applications.
            wireplumber.enable = true;
        };

        # Low-latency setup
        #services.pipewire.extraConfig.pipewire."92-low-latency" = mkIf cfg.lowlatency {
            #context.properties = {
                #default.clock.rate = 48000;
                #default.clock.quantum = 32;
                #default.clock.min-quantum = 32;
                #default.clock.max-quantum = 32;
            #};
        #};

        # Packages
        environment.systemPackages = with pkgs; [
            easyeffects
        ];
    };
}
