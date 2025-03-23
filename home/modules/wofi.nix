{ config, pkgs, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) wofi; };
    xdg.configFile = {
        "wofi/config".source = config.lib.file.mkOutOfStoreSymlink ./config;
        "wofi/style.css".source = config.lib.file.mkOutOfStoreSymlink ./style.css;
    };

   #programs.wofi = {
   #    enable = true;
   #    settings = {
   #
   #        # Configuration
   #        prompt = "「何を探しているのですか？」";
   #        #term = "alacritty";
   #        line_wrap = "word";
   #
   #        #print_command = true;
   #        #display_generic = false;
   #        #gtk_dark = true;
   #        #layer = "overlay";
   #    
   #        key_expand = "Tab";
   #        insensitive = true;
   #        show = "drun";
   #        width = "30%";
   #        location = "top_right";
   #        lines = 30;
   #        sort_order = "alphabetical";
   #        hide_scroll = true;
   #        allow_markup = true;
   #
   #        # Icons
   #        allow_images = true;
   #        image_size = 18;
   #    };
   #
#       style = ''
#       /* Font */
#       * {
#	        font-family: 'JetBrains Mono Nerd Font', monospace;
#		    font-size: 20px;
#	    }
#       
#       /* Window */
#       window {
#           margin: 10px;
#               padding: 10px;
#               border: 0px black;
#               border-radius:0px;
#               background-color: black;
#           }
#
#           #input {
#               margin: 5px;
#               border: 2px black;
#               color: white;
#               background-color: black;
#           }
#
#           #inner-box {
#               margin: 5px;
#               border: 2px black;
#               background-color: black;
#           }
#
#           #outer-box {
#               margin: 5px;
#               border: 2px black;
#               background-color: black;
#           }
#
#           #scroll {
#               margin: 5px;
#               border: 2px black;
#               background-color: black;
#           }
#
#           #text {
#               margin: 5px;
#               /* border: 2px white; */
#               background-color: black;
#           }
#
#           #entry:selected {
#           color: white;
#           background-color: rgba(0,0,0,0);
#
#           #text:selected {
#           color: white;
#           background-color: black;
#           }
#       '';
#};
}
