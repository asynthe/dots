{ config, lib, ... }:
let
    cfg = config.sys.modules.audio;
in {
    options.sys.modules.audio = {
        enable = lib.mkEnableOption "Audio via Pipewire";
    };

    config = lib.mkIf cfg.enable {
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            audio.enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
            wireplumber.enable = true;
        };
    };
}
