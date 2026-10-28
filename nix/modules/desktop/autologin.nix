_: {
  flake.modules.nixos.autologin = { config, ... }: {
    services.getty.autologinUser = config.sys.user;
    services.getty.autologinOnce = true;
  };
}
