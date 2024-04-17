{ config, pkgs, pkgs-unstable, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs-unstable)
	    #tshark
	;
        inherit (pkgs)

	    # Testing
	    inetutils
	    vsftpd

	    # Brute Forcing
	    thc-hydra

	    # Image
	    exiftool

	    # Assess
	    seclists
	    wfuzz
	    whatweb
	    ffuf

	    # Proxy
	    #burpsuite

	    # CLI
	    lsof
	    usbutils

	    # Scanning
	    masscan	
	    nmap
	    rustscan

	    # Networking
	    arp-scan
	    netdiscover
	    macchanger
	    netcat-openbsd
	    socat
	    tcpdump
	    #tshark
	    wireshark #wireshark-cli

	    # Recon
	    gobuster

	    # Tools
	    bc
	    curl
	    jq

	    # Web
	    burpsuite
	;
	inherit (pkgs.unixtools)
	    xxd
	;
    };
}
