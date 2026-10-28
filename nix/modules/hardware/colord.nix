_: {
  flake.modules.nixos.colord = _: {
    services.colord.enable = true;
  };
}
