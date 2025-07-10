{ config, pkgs, lib, ... }: 
with lib; with types;
let
    cfg = config.meta.audio.bluetooth;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.audio.bluetooth.enable = mkEnableOption "Enable Bluetooth service.";
    options.meta.audio.bluetooth.no_handsfree_mode = mkEnableOption "Disable handsfree profile.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.blueman.enable = true;
        hardware.bluetooth = {
            enable = true;
            package = pkgs.bluez;
            powerOnBoot = true;
            settings.General = mkIf cfg.no_handsfree_mode {
                #Enable = "Source,Sink,Headset,Gateway,Handsfree";
                Disable = "Headset";
                DiscoverableTimeout = 0;
                FastConnectable = true;
            };
            settings.Policy.AutoEnable = true;
        };

        # Packages
        environment.systemPackages = with pkgs; [
            bluez-tools
            bluetuith # Bluetooth ncurses frontend.
        ];

        # Configuration
        services.pipewire.wireplumber.extraConfig = mkIf cfg.no_handsfree_mode {

            # Don't switch to that annoying headset profile.
            "11-bluetooth-policy"."wireplumber-settings"."bluetooth.autoswitch-to-headset-profile" = false;

            "50-bluez" = {
                "monitor.bluez.rules" = [
                    {
                        matches = [ { "device.name" = "~bluez_card.*"; } ];
                        actions.update-props."bluez5.auto-connect" = [ "a2dp_sink" "a2dp_source" ];
                        actions.update-props."bluez5.hw-volume" = [ "a2dp_sink" "a2dp_source" ];
                    }
                ];
                "monitor.bluez.properties" = {
                    "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" ];
                    "bluez5.hfphsp-backend" = "none";
                    "bluez5.codecs" = [
                        "ldac"
                        "aptx"
                        "aptx_ll_duplex"
                        "aptx_ll"
                        "aptx_hd"
                        "opus_05_pro"
                        "opus_05_71"
                        "opus_05_51"
                        "opus_05"
                        "opus_05_duplex"
                        "aac"
                        "sbc_xq"
                    ];
                };
            };
        };
    };
}
