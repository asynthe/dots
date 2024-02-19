{ config, pkgs, ... }: {

  services.mpd = {
    enable = true;
    musicDirectory = "/home/ben/music";
    #musicDirectory = "/home/${username}/music";
    #network.startWhenNeeded = false; # Socket activation.
    extraConfig = ''

      # REQUIRED
      db_file "~/.config/mpd/database"
      log_file "~/.config/mpd/log"
      
      # MAIN
      playlist_directory "~/.config/mpd/playlists"
      # pid_file "~/.config/mpd/pid"
      # state_file "~/.config/mpd/state"
      # sticker_file "~/.config/mpd/sticker.sql"
      
      # OTHER
      log_level	"notice"
      auto_update	"yes"
      #auto_update_depth "3"
      #bind_to_address "127.0.0.1"
      #port "6600"
      
      # OUTPUT
      #audio_output {
      #	type		"pulse"
      #	name		"Pulse Output"
      #	mixer_control	"Master"
      #}
      #audio_output {
      	#type		"pipewire"
      	#name		"PipeWire Sound Server"
      #}
      
      # VISUALIZER
      # buffer_time "100000"
      #audio_output {
      #type            "fifo"
      #name            "my_fifo"
      #path            "/tmp/mpd.fifo"
      #format          "44100:16:2"
      #}
     '';
  };

}
