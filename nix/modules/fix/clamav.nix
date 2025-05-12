{
    services.clamav = {
        daemon = {
	        enable = true;
	        #settings = ;
	    };
        updater = {
	        enable = true;
	        #interval = ""; # default `hourly`.
	        #frequency = 12; # default `12`.
	        #settings = ;
	    };
    };
}
