_: {
  flake.modules.nixos.fingerprint =
    { lib, ... }:
    let
      finger = [
        "sudo"
        "su"
        "polkit-1"
        "systemd-run0"
      ];
    in
    {
      # Password-only everywhere except the list; tty login and hyprlock's own password check included.
      services.fprintd = {
        enable = true;
        enablePam = false;
      };

      # hyprlock reads the sensor itself (auth.fingerprint in hyprlock.conf).
      programs.hyprlock.enable = true;

      security.pam.services = lib.genAttrs finger (_: {
        fprintAuth = true;
        rules.auth.fprintd.args = [
          "max-tries=2"
          "timeout=10"
        ];
      });

      sys.persist.directories = [ "/var/lib/fprint" ];
    };
}
