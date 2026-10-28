_: {
  flake.modules.nixos.flatpak = _: {
    services.flatpak.enable = true;

    sys.persist.directories = [ "/var/lib/flatpak" ];
  };
}
