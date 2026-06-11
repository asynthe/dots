{ pkgs, ... }: {
    services.syncthing = {
        enable = true;
	openDefaultPorts = true;
    };
    networking.firewall.allowedTCPPorts = [ 8384 ];
}
