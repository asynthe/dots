{ pkgs, ... }: {
    home.packages = builtins.attrValues {
        inherit (pkgs)
            wezterm
            linthesia
	        #ciscoPacketTracer8
	        #gns3-gui gns3-server
	        #slides
	        #zoom-us
	        #slack #slack-cli #slack-term # ?
        ;
    };
}
