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

    flake.modules.nixos.pentest = { config, lib, pkgs, ... }: {
        programs.wireshark = {
            enable  = true;
            package = pkgs.wireshark;
        };
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "wireshark" ]; });

        environment.systemPackages = with pkgs; [
            masscan
            rustscan
            arp-scan
            whatweb

            amass
            dnsrecon
            subfinder
            #theharvester

            burpsuite
            feroxbuster
            ffuf
            gobuster
            katana
            nikto
            nuclei
            sqlmap
            wpscan

            sslscan
            testssl

            bettercap
            mitmproxy
            termshark

            aircrack-ng
            kismet

            cewl
            hashcat
            hashid
            john
            thc-hydra

            enum4linux
            netexec
            responder
            smbmap

            exploitdb
            metasploit

            binwalk
            checksec
            gef
            pwntools
            radare2
            #ghidra     # ~1 GB, uncomment when actually reversing

            chisel
            ligolo-ng
            proxychains-ng
            socat

            seclists
            #wordlists # not working

            social-engineer-toolkit
        ];
    };
}
