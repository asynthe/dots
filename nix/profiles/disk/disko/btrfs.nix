{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.disk;
in {
    config = mkIf (cfg.filesystem == "btrfs") {

        boot = {
            supportedFilesystems = [ "btrfs" "vfat" ];
            #resumeDevice = "/dev/disk/by-label/nixos";
            # encryption enabled !
            #initrd.luks.devices."encrypted".allowDiscards = config.meta.disk.encryption.enable;
        };

        disko.devices = {

            # ─────────────── Impermanence - tmpfs ───────────────
            nodev."/" = mkIf cfg.persistence.enable {
	            fsType = "tmpfs";
	            mountOptions = [ "size=4G" "defaults" "mode=0755" ];
	        };

            # Main disk
            disk.main = {
                type = "disk";
                device = cfg.device;
                content.type = "gpt";
                content.partitions = {
            
		            # EFI partition
		            boot = {
		                priority = 1;
		                name = "boot";
		                size = "512M";
		                type = "EF00";
			            content.type = "filesystem";
			            content.format = "vfat";
			            content.mountpoint = "/boot";
			            content.mountOptions = [ "defaults" ];
		            };

                    # ─────────────── Non-encrypted Impermanence ───────────────
		            data = mkIf (cfg.persistence.enable && !cfg.encryption.enable) {
		                size = "100%";
			            content.type = "btrfs";
			            content.subvolumes = {
                
			                home.type = "filesystem";
			                home.mountpoint = "/home";
			                home.mountOptions = [ "compress=zstd" ];
                
			                nix.type = "filesystem";
			                nix.mountpoint = "/nix";
			                nix.mountOptions = [ "compress=zstd" ];
                
			                persist.type = "filesystem";
			                persist.mountpoint = "/persist";
			                persist.mountOptions = [ "compress=zstd" ];
                
			                log.type = "filesystem";
			                log.mountpoint = "/var/log";
			                log.mountOptions = [ "compress=zstd" ];
			            };
		            };

                    # ─────────────── LUKS encrypted + Impermanence ───────────────
                    main = mkIf (cfg.persistence.enable && cfg.encryption.enable) {
                        size = "100%";
                        label = "luks";
                        content.type = "luks";
                        content.name = "encrypted"; # This is the name of /dev/mapper device
                        content.settings = {
                            allowDiscards = true; # SSD optimization
                            bypassWorkqueues = true; # SSD optimization
                        };
                        content.extraOpenArgs = [
                            #"--allow-discards"
                            #"--perf-no_read_workqueue"
                            #"--perf-no_write_workqueue"
                            "--timeout 10"
                        ];

                        # Cipher options and more
                        #content.extraFormatArgs = [
                            #"--type luks2"
                            #"--cipher aes-xts-plain64"
                            #"--hash sha512"
                            #"--iter-time 5000"
                            #"--key-size 256"
                            #"--pbkdf argon2id"
                            # Use true random data from /dev/random, block until enough entropy is available.
                            #"--use-random"
                        #];

                        content.content.type = "btrfs";
                        content.content.extraArgs = [ "-f" ];
                        content.content.subvolumes = {

                            # Swap
                            # If config.meta.system.disk.swap then
                            #"/swap" = {
                                #mountpoint = "/swap";
                                #swap.swapfile.size = config.meta.system.disk.swap;
                            #};

                            "/nix" = {
                                mountpoint = "/nix";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };

                            "/snapshots" = {
                                mountpoint = "/snapshots";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };

                            "/home" = {
                                mountpoint = "/home";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };

                            "/persist" = {
                                mountpoint = "/persist";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };

                            "/log" = {
                                mountpoint = "/var/log";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };
                        };  
                    };
                };
            };

            # ─────────────── Second disk (to use as /home) ───────────────
            #disk.second = {
            #    type = "disk";
            #    device = cfg.device_second;
            #    content.type = "gpt";
            #    content.partitions = {

            #       # /home
            #        home = {
            #            size = "100%";
            #            type = "filesystem";
            #            format = "btrfs";
            #            label = "home";
            #            mountpoint = "/home";
            #            mountOptions = [ "compress=zstd" "noatime" ];
            #        };
            #    };
            #};
        };
    };
}
