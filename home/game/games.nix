{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)
            #minecraft #minecraft-server
            gzdoom
            #zandronum #zandronum-server
            stepmania
            #osu-lazer # No score submission or multiplayer.
            #osu-lazer-bin # AppImage ver. (w score submission and multiplayer)
            #clonehero # NOT WORKING (17-09-2023)

	        # Marathon
	        #alephone
	        #alephone-marathon
	        #alephone-durandal
	        #alephone-infinity

	        #alephone-eternal
	        #alephone-evil
	        #alephone-apotheosis-x # Needs nix-store importing, get from `https://www.moddb.com/mods/apotheosis-x/downloads`.
	        #alephone-rubicon-x
        ;
    };
}
