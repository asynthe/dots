{ config, lib, pkgs, ... }: {

    home.packages = builtins.attrValues { inherit (pkgs) cli-visualizer; };
    home.file = {
        "${config.xdg.configHome}/vis/config".source = config.lib.file.mkOutOfStoreSymlink ./config;
        "${config.xdg.configHome}/vis/colors/blue".text = "blue";
        "${config.xdg.configHome}/vis/colors/cyanred".text = "#0099ff\n#ff3399";
        "${config.xdg.configHome}/vis/colors/cyberpunk".text = "#BCECEO\n#36EEEO\n#F652AO\n#4C527O";
        "${config.xdg.configHome}/vis/colors/deepblue".text = "#7EC8E3\n#0000FF\n#000C66\n#050A30";
        "${config.xdg.configHome}/vis/colors/deepblue-inverted".text = "#050A30\n#000C66\n#0000FFn#7EC8E3";
        "${config.xdg.configHome}/vis/colors/dreamy".text = "#94e2d5\n#89dceb\n#74c7ec\n#89b4fa\n#cba6f7\n#f5c2e7\n#eba0ac\n#f38ba8";
        "${config.xdg.configHome}/vis/colors/rainbow".text = "#1F80F3\n#08ADD8\n#06B3D4\n#01D7AF\n#01DBA9\n#0DF47E\n#26FE53\n#2CFF4B\n#4FF829\n#58F522\n#83DE0B\n#8FD506\n#ADBB01\n#BEAA01\n#D78C07\n#E27C0D\n#F65525\n#F94C2B\n#FE2A4D\n#FE2456\n#F20B81\n#D901AC\n#D501B2\n#B007D6\n#AA09DA\n#7C21F4\n#6D2DF9\n#5541FE\n#3E58FE\n#2A70F9\n";
        "${config.xdg.configHome}/vis/colors/sakura".text = "#FCD1D7\n#FFE7DE\n#E9B1CD\n#C3829E\n#562135";
        "${config.xdg.configHome}/vis/colors/sakura-inverted".text = "#eb6f92\n#f6c177\n#ebbcba\n#c4a7e7\n#9ccfd8\n#31748f";
        "${config.xdg.configHome}/vis/colors/white".text = "white";
    };
}
