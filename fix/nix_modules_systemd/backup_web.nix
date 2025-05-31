{ config, pkgs, lib, user, ... }: 

let

    script = pkgs.writeShellApplication {
        name = "web-backup-script";
	runtimeInputs = with pkgs; [ rsync ];
	text = ''

	  # Firefox bookmarks
	  rsync -a --delete \
	  /home/${user}/.librewolf/sbm2zibt.default/bookmarkbackups/ \
	  /home/${user}/sync/study/backup/bookmarks

	  # Simple tab groups backup
	  rsync -a --delete \
	  /home/${user}/Downloads/tab-group-backups/ \
	  /home/${user}/sync/study/backup/tab-groups
	'';
    };

in {

    systemd.user = {
        services.backup-web = {
	    Unit.Description = "Backup of bookmarks and tab groups";
	    Service = {
                Type = "oneshot";
		Restart = "on-failure";
		RestartSec = "2m";
                ExecStart = "${script}/bin/web-backup-script";
            };
	};
        timers.backup-web = {
	    Unit.Description = "Timer for web backup service";
            Install.WantedBy = [ "timers.target" ];
            Timer.OnCalendar = "*:0/10"; # Every 10 minutes.
        };
    };
}
