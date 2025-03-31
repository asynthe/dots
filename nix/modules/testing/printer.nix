{ config, pkgs, user, ... }: {

    users.users.${user}.extraGroups = [ "cups" "scanner" "lp" ];
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplipWithPlugin ];
    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
	        xsane
	    ;
    };

    # Scanning
    hardware.sane.enable = true;
	hardware.sane.extraBackends = [ 
	    pkgs.hplipWithPlugin
	    pkgs.sane-airscan
	];
	#disabledDefaultBackends = [ "escl" ];
    services.ipp-usb.enable = true;

    # Autodiscovery of network printers
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };
}
