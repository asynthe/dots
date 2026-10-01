{ ... }:
{
    flake.modules.nixos.syncthing = { ... }: {
        services.syncthing.enable = true;
        services.syncthing.openDefaultPorts = true;
        networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}
