_: {
  # TODO Make autostart
  flake.modules.nixos.mullvad = _: {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.gui.enable = true;
    #services.mullvad-vpn.enableEarlyBootBlocking = true;

    sys.persist.directories = [ "/etc/mullvad-vpn" ];
  };
}
