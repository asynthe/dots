{ config, pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
            spotify-player
            spotify-cli-linux
        ;
    };

    programs.ncspot = {
        enable = true;
        #settings = {
        #};
    };

    services.spotifyd = {
        enable = true;
        package = pkgs.spotifyd.override {
            #withKeyring = true;
            withPulseAudio = true;
            withMpris = true;
        };
        #settings = {
            #username = "";
            #password = "";
            #device_name = config.networking.hostName;
            #initial_volume = "80";
            #volume-normalisation = true;
        #};
    };
}
