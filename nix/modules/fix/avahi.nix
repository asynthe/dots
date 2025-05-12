{ pkgs, ... }: {

    networking.firewall.allowedTCPPorts = [ 8010 ];
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };

    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
            vlc
        ;
    };

}
