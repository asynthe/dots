_: {
  flake.modules.nixos.firmware = _: {
    services.fwupd.enable = true;

    sys.persist.directories = [ "/var/lib/fwupd" ];
  };
}
