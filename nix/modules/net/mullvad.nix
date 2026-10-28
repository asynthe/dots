_: {
  flake.modules.nixos.mullvad = _: {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.gui.enable = true;

    sys.persist.directories = [ "/etc/mullvad-vpn" ];
  };
}
