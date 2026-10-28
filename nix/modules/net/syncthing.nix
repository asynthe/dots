_: {
  flake.modules.nixos.syncthing = _: {
    services.syncthing.enable = true;
    services.syncthing.openDefaultPorts = true;
    networking.firewall.allowedTCPPorts = [ 8384 ];
  };
}
