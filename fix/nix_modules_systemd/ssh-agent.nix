{ config, pkgs, username, ... }: {

  # The service
  systemd.user.services."ssh-agent" = {
    serviceConfig.Type = "simple";
    wantedBy = [ "default.target" ];
    environment = {
      SSH_AUTH_SOCK=%t/ssh-agent.socket
    };
    path = with pkgs; [ bash gnutar gzip ];
    script = ''
      
    '';
  };

  # The Timer
  systemd.user.timers."backup_notes" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "test-backup.service" ];
    timerConfig = {
      OnCalendar = "0/3:00:00"; # Every 3 hours, starting from 24.
      Persistent = true;
    };
  };

}
