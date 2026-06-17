/*
https://github.com/farberbrodsky/nix/blob/fe6757ddc74535473aaa8b123d86b5d565e18863/system/btrfs-impermanence.nix
https://github.com/ilkecan/config/blob/1ae5c7b74022deb39d1d33995898fb4c6f8e8302/nix/hosts/mephistopheles/impermanence.nix
*/

{ config, lib, ... }: 
let
    cfg = config.sys.modules.impermanence;
in {
    options.sys.modules.impermanence = {
        enable = lib.mkEnableOption "Impermanence";
    };

    config = lib.mkIf cfg.enable {
        fileSystems = {
            "/persist".neededForBoot = true;
            "/var/log".neededForBoot = true;
            # TODO NOTE
            # Should it be good to save all of this, or better to save specific directories?
        };

        environment.persistence."/persist" = {
            hideMounts = true;
            directories = [
                "/etc/nixos" # TODO which one?
                "/var/lib/nixos"
                "/var/lib/fwupd" # TODO fwupdmgr update
                "/var/lib/systemd" # https://nixos.org/manual/nixos/unstable/#sec-var-systemd
                #"/var/lib/systemd/coredump"
            ];
            files = [
                "/etc/machine-id"
                "/etc/adjtime" # Hardware clock # TODO Check
                "/var/lib/systemd/random-seed"
                #"/root/.bash_history"

                # ZSH
                #"/etc/zfs/zpool.cache"

                # agenix
                # TODO Set a proper secret management
                #"/etc/ssh/ssh_host_ed25519_key"
                #"/etc/ssh/ssh_host_ed25519_key.pub"
                #"/etc/ssh/ssh_host_rsa_key"
                #"/etc/ssh/ssh_host_rsa_key.pub"
            ];
        };

        boot.initrd.systemd.services.rollback = {
            description = "Rollback BTRFS root subvolume to a blank state";
            wantedBy = [ "initrd.target" ];
            after = [ "initrd-root-device.target" ]; # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/7
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = false;
            serviceConfig.Type = "oneshot";
            script = ''
      mkdir /btrfs_tmp
      mount /dev/disk/by-label/nixos /btrfs_tmp

      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          btrfs subvolume delete --recursive "$i"
      done

      btrfs subvolume snapshot /btrfs_tmp/root-blank /btrfs_tmp/root
      umount /btrfs_tmp
      '';
        };
    };
}
