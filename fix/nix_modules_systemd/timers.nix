{ config, pkgs, ... }: {

  # Enable custom systemd services and timers.
  imports = [

    # Automated Backups
    #../../../modules/nix/timer/backup_notes.nix # Simple user unit that runs a backup script.

  ];
}
