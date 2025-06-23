# TODO
# DISABLE ALL THOSE THAT ARE ENABLED BY DEFAULT with `services.i2pd.enable`
# i2pd configuration, using defaults from here
# https://i2phides.me/i2pd-docs/user-guide/configuration/index.html

{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.i2pd;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.i2pd.enable = mkEnableOption "Enable and set I2PD.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.i2pd = {
            enable = true;
            bandwidth = 500; # i2pd defaults to 32kbps.
            dataDir = "/home/${user}/.cache/i2pd";
            logLevel = "info"; # debug, info, warn, error
            netid = 2;

            nat = true; # Bypass NAT.
            port = 29988;
            #ifname = "wg-mullvad"; # Network interface to bind to.
            enableIPv4 = true;

            #ifname4 = ; # IPv4 interface to bind to.
            #enableIPv6 = true;
            #ifname6 = ; # IPv6 interface to bind to.
            ssu = true;

            ntcp = true;
            #ntcpProxy = ; # Proxy URL for NTCP transport.
            ntcp2 = {
                enable = true;
                #port = ;
                published = true;
            };

            # UPNP
            upnp = {
                enable = true; # false by default for CLI, true for GUI. (Windows, Android)
                name = "I2Pd";
            };

            proto = {
                # HTTP webconsole
                http = {
                    enable = true;
	                address = "127.0.0.1"; # Bind address.
	                port = 7070; # CUSTOM CONFIGURATION
	                hostname = "localhost";
	                #auth = true; # Webconsole authentication.
	                #user = "i2pd";
	                #pass = "i2pd"; # Default: random, see logs.
	                strictHeaders = true; # Strict host checking on WebUI.
                };
                httpProxy.enable = true; # HTTP proxy
                socksProxy.enable = true; # Socks proxy
                sam.enable = true;
                bob.enable = false;
                i2pControl.enable = false; # I2PControl interfaces
                #websocket = {
                    #enable = true;
                    #name = ;
                    #port = ;
                #};
            };
        };

        # Outbound NAT rule must be created.
        # https://forum.opnsense.org/index.php?topic=15924.0

        #networking.nat.forwardPorts = [{
            #destination = "10.0.0.1:35467";
            #proto = "tcp";
            #sourcePort = 8080;
        #}];

        #networking.firewall = {
            #enable = true;
            #interfaces = {
                #"wg-mullvad".allowedTCPPorts = [ 80 443 29988 ];
                #"wlp3s0".allowedTCPPorts = [ 80 443 29988 ];
            #};
        #};

        # W NAT
        #networking.nat.forwardPorts

        # WO NAT
        #networking.firewall = {
            #extraCommands = "iptables -I FORWARD ...";
            #extraStopCommands = "iptables -D FORWARD ... || true";
        #};
    };
}
