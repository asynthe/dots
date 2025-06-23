{ config, pkgs, lib, ... }: 
with lib; with types;
let
    cfg = config.meta.audio.bluetooth;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.audio.bluetooth.enable = mkEnableOption "Enable Bluetooth service.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.blueman.enable = true;
        hardware.bluetooth = {
            enable = true;
            package = pkgs.bluez;
            powerOnBoot = true;
            settings.General = {
                #Enable = "Source,Sink,Headset,Gateway,Handsfree";
                Disable = "Headset";
                DiscoverableTimeout = 0;
                FastConnectable = true;
            };
            settings.Policy.AutoEnable = true;
        };

        environment.systemPackages = with pkgs; [
            bluez-tools
            bluetuith # Bluetooth ncurses frontend.
        ];

        #services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = mkIf config.services.pipewire.enable {
            #"monitor.bluez.properties" = {
                #"bluez5.enable-sbc-xq" = true;
                #"bluez5.enable-msbc" = true;
                #"bluez5.enable-hw-volume" = true;
                #"bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            #};
        #};
    };
}
