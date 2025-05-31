{ pkgs, ... }: {
    home = {
        packages = builtins.attrValues { inherit (pkgs) swappy; };
        file.".config/swappy/config".text = ''
          [Default]
          save_dir=$XDG_SCREENSHOTS_DIR
          #save_filename_format=
          show_panel=false # Show panel on start
          early_exit=true # Exit on export
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          fill_shape=false
        '';
    };
}
