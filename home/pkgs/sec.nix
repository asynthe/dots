{ pkgs, pkgs-stable, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs-stable)
            wfuzz
        ;
        inherit (pkgs)
            # CLI
            vulnix
            bleachbit
            
            # Tools
            sqlmap # SQL Injection
            wpscan # Wordpress
            joomscan # Joomla
            exiftool # Image
            seclists # Dictionaries and more
            #social-engineer-toolkit
            snort
            
            # Framework
            #metasploit
            
            # OSINT
            maltego
            sherlock
            
            # Pentesting
            netexec #crackmapexec # Crackmapexec is unmantained.
            exploitdb # `searchsploit`
            
            # Brute Forcing
            thc-hydra

            # Password / Hash Cracking
            hash-identifier
            hashcat hashcat-utils
            hcxtools
            john
            
            # Networking
            arp-scan
            macchanger
            netcat-openbsd rlwrap
            netdiscover
            socat
            tcpdump
            dsniff
            #tshark
            wireshark #wireshark-cli
            
            # Networking - Port Scanning
            masscan	
            nmap # A utility for network discovery and security auditing.
            rustscan
            
            # Scanning
            nikto
            
            # Web
            burpsuite
            openssl
            
            ## Fuzzing
            dirb
            dirbuster
            ffuf
            gobuster
            ## Recon
            whatweb
            amass
            assetfinder
            gowitness
            httprobe
            subfinder
            whois
            #sslyze # Not on nixpkgs.
            sslscan
            
            # SMB / Samba
            cifs-utils
            samba
            smbmap
            
            # Wi-Fi
            aircrack-ng
	    ;
	    inherit (pkgs.unixtools) xxd;
    };
}
