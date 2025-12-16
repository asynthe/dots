{ config, pkgs, lib, nixos-06cb-009a-fingerprint-sensor, ... }:

with lib;
let

  cfg = config.thinkpad.t480.fingerprint;

in {

  #services = {
    #open-fprintd.enable = true;
    #python-validity.enable = true;
  #};

  options.thinkpad.t480.fingerprint.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable fingerprint drivers.";
  };

  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;

      # Touch OEM Drivers library support.
      tod = {       
        enable = true;
        driver = nixos-06cb-009a-fingerprint-sensor.lib.libfprint-2-tod1-vfs0090-bingch {
          calib-data-file = ./calib-data.bin;
        };
      };
    };

    security.pam.services = {

      #test.text = ''
        #auth required pam_env.so
        #auth sufficient pam_fprintd.so
        #auth sufficient pam_unix.so try_first_pass likeauth nullok
        #auth required pam_deny.so
      #'';

      sudo.text = ''
        # Account management.
        account required pam_unix.so
  
        # Authentication management.
        auth sufficient pam_unix.so likeauth try_first_pass nullok
        auth sufficient ${nixos-06cb-009a-fingerprint-sensor.localPackages.fprintd-clients}/lib/security/pam_fprintd.so
        auth required pam_deny.so
  
        # Password management.
        password sufficient pam_unix.so nullok sha512
  
        # Session management.
        session required pam_env.so conffile=/etc/pam/environment readenv=0
        session required pam_unix.so
      '';

      #gtklock.text = ''
        #auth sufficient pam_unix.so try_first_pass likeauth nullok
        #auth sufficient pam_fprintd.so
      #'';
    };
  };

}
