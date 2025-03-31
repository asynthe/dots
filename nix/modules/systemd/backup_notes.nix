{ config, pkgs, username, ... }: {

  # The service
  systemd.user.services."backup_notes" = {
    serviceConfig.Type = "oneshot";
    #wantedBy = [ "default.target" ]; # Test with this line.
    path = with pkgs; [ bash gnutar gzip ];
    script = ''
      bash /home/${username}/sync/dots/script/bash/timer/backup/backup_notes.sh
      bash /home/${username}/sync/dots/script/bash/timer/backup/backup_notes_delete_old_1_minute.sh
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
