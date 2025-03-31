{ config, pkgs, ... }: {

  systemd.services.my-repeating-task = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash ];
    script = ''
      bash /home/asynthe/flake/modules/nix/timer/myscript.sh
    '';
  };

  systemd.timers.my-repeating-task = {
    wantedBy = [ "timers.target" ];
    partOf = [ "my-repeating-task.service" ];
    timerConfig = {
      OnCalendar = "*:0/1";
      Unit = "my-repeating-task.service";
    };
  };

}
