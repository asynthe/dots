{ config, ... }: {

    imports = [
        #./mpd-discord-rpc.nix
        #./mpdris2.nix
    ];

    # Note, run `systemctl --user start mpd.service`
    services.mpd = {
        enable = true;
        musicDirectory = config.xdg.userDirs.music;
        network = {
            listenAddress = "any";
            startWhenNeeded = true;
        };
        extraConfig = ''
          auto_update           "yes"
          restore_paused        "yes"
          filesystem_charset    "UTF-8"

          #volume_normalization  "yes"
          #replaygain "auto"
          #replaygain "track"
          #replaygain_missing_preamp "0"
          #replaygain_limit "yes"

          audio_output {
            type                "pipewire"
            name                "PipeWire"
          }

          audio_output {
            type                "fifo"
            name                "Visualiser"
            path                "/tmp/mpd.fifo"
            format              "44100:16:2"
          }

          audio_output {
           type		              "httpd"
           name		              "lossless"
           encoder		          "flac"
           port		              "8000"
           max_clients	        "8"
           mixer_type	          "software"
           format		            "44100:16:2"
          }
        '';
    };
}
