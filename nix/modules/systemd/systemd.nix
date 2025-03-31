{ config, pkgs, ... }: {

  # This is a test of a systemd timer declarated in a NixOS system.
  # https://www.codyhiar.com/blog/repeated-tasks-with-systemd-service-timers-on-nixos/

  #systemd.services.my-repeating-task = {
  #serviceConfig.Type = "oneshot";
  #path = with pkgs; [ bash ];
  #script = ''
  #bash /home/asynthe/sync/system/script/nix_sysd_timer_test.sh
  #'';
  #};
  #systemd.timers.my-repeating-task = {
  #wantedBy = [ "timers.target" ];
  #partOf = [ "my-repeating-task.service" ];
  #timerConfig = {
  #OnCalendar = "*:0/1";
  #Unit = "my-repeating-task.service"
  #};
  #};

  # This is the test from the nixos wiki page for reference.

  ##### ROOT #####

  #systemd = {
    # SERVICES
    #services = {
      #"hello-world" = {
        #serviceConfig = {
          #Type = "oneshot";
          #User = "root";
        #};
        #script = ''
          #set -eu
          #${pkgs.coreutils}/bin/echo "Hello World"
        #'';
      #};
    #};

    # TIMERS
    #timers = {
      #"hello-world" = {
        #wantedBy = ["timers.target"];
        #timerConfig = {
          #OnBootSec = "5m";
          #OnUnitActiveSec = "5m";
          #Unit = "hello-world.service";
        #};
      #};
    #};
  #};

  ##### USER #####

  #systemd.user = {

    # SERVICES
    #services = {
      #"swww-wallpaper" = {
        #enable = true;
        #wantedBy = ["default.target"];
        #serviceConfig = {
          #Type = "oneshot";
          #User = "asynthe";
        #};
        #path = with pkgs; ["fd" "swww" "pywal"];
        #script = "exec /home/asynthe/sync/system/script/dots/swww_random.sh";
      #};
    #};

    # TIMERS
    #timers = {
      #"swww-wallpaper" = {
        #wantedBy = ["timers.target"];
        #timerConfig = {
          #OnBootSec = "30s";
          #OnUnitActiveSec = "30s";
          #Unit = "swww-wallpaper.service";
        #};
      #};
    #};
  #};
}
