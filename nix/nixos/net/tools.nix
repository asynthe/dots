{ ... }:
{
    flake.modules.nixos.net-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bandwhich
            nethogs
            speedtest-cli
        ];
    };

    flake.modules.nixos.soc-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            hping
            net-tools
            nmap
            tcpdump
            foremost
        ];
    };

    # Offensive tooling, several GB. Split from soc-tools so a server can skip it.
    flake.modules.nixos.pentest = { config, pkgs, ... }: {
        # The setcap wrapper and dumpcap group are what let capture run unprivileged.
        programs.wireshark = {
            enable  = true;
            package = pkgs.wireshark;
        };
        users.users.${config.sys.user}.extraGroups = [ "wireshark" ];

        environment.systemPackages = with pkgs; [
            # scanning
            masscan
            rustscan
            arp-scan
            whatweb

            # dns / osint
            amass
            dnsrecon
            subfinder
            theharvester

            # web
            burpsuite
            feroxbuster
            ffuf
            gobuster
            katana
            nikto
            nuclei
            sqlmap
            wpscan

            # tls
            sslscan
            testssl

            # traffic / mitm
            bettercap
            mitmproxy
            termshark

            # wireless
            aircrack-ng
            kismet

            # credentials
            cewl
            hashcat
            hashid
            john
            thc-hydra   # `hydra` is the Nix CI server, not the cracker

            # smb / ad
            enum4linux
            netexec
            responder
            smbmap

            # exploitation
            exploitdb   # searchsploit
            metasploit

            # binary / re
            binwalk
            checksec
            gef
            pwntools
            radare2
            #ghidra     # ~1 GB, uncomment when actually reversing

            # pivoting
            chisel
            ligolo-ng
            proxychains-ng
            socat

            # wordlists
            seclists
            #wordlists # not working

            # se
            social-engineer-toolkit
        ];
    };
}
