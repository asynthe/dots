{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.services.sshfs;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.sshfs.enable = mkEnableOption "Set up an automatic connection to the server through a SSHFS folder.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable { 

        environment.systemPackages = with pkgs; [ sshfs ];
        services.openssh.allowSFTP = true; # Allow SFTP, which is used by SSHFS.
        users.users.${config.meta.system.user}.extraGroups = [ "fuse" ]; # Add to FUSE group and enable allow_other.
        programs.fuse.userAllowOther = true; # ?

        # https://github.com/Baughn/machine-config/blob/e609d1eab19ee2836203f7897380aefb956afca4/saya/hardware-configuration.nix#L28
        # https://github.com/soltros/configbuilder/blob/6f58652ad89f2677dddf6bc7997e42c3caf5842a/modules/sshfs-mounts.nix#L5
        # -------------------------------------------------------------------------------
        
        #systemd.user.services."sshfs_automount" = {
            #serviceConfig.Type = "oneshot";
	        #path = with pkgs; [ bash sshfs ];
	        #script = ''
	          #bash /home/${username}/sync/dots/script/bash/timer/sshfs_automount.sh
	        #'';
        #};

        #systemd.user.timers."sshfs_automount" = {
            #wantedBy = [ "timers.target" ];
	        #partOf = [ "ssfs_automount.service" ];
	        #timerConfig = {
	            #OnCalendar = "0/2:00:00";
	            #OnCalendar = "00/2:00";
	        #};
        #};

        #system.fsPackages = [ pkgs.sshfs ];
        #fileSystems.sshfs_server = {
            #device = "ben@100.122.54.91:~/";
            #mountPoint = "/mnt/server";
            #fsType = "sshfs";
            #options = [
                #"allow_other"
                #"_netdev"
                #"x-systemd.automount"

                # The ssh key must not be encrypted, have 
                # strict permissions (like 600) and be owned by root.
                #"IdentityFile=/home/asynthe/sync/ben/pass/ssh/thinknya"

                # Handle connection drops better
                #"ServerAliveInterval=15"
                #"reconnect"

                # You can specify some of the ssh_config(5)
                # options, for example:
                #"ProxyJump=bastion@example.com"
                #"Port=22"

                # You can also change the ssh command.
                # Note: in any option spaces must be
                # escaped because it goes to /etc/fstab,
                # a table of space-separated fields.
                #(builtins.replaceStrings [" "] ["\\040"]
                #  "ssh_command=${pkgs.openssh}/bin/ssh -v -L 8080:localhost:80")

                # Uncomment this if you're having a hard time
                # figuring why mounting is failing.
                #"debug"
            #];
        #};
    };
}
