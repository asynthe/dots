_: {
  flake.modules.nixos.fingerprint = _: {
    services.fprintd.enable = true;
    security.pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
    };

    sys.persist.directories = [ "/var/lib/fprint" ];
  };
}
