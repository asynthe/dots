/*
https://github.com/farberbrodsky/nix/blob/fe6757ddc74535473aaa8b123d86b5d565e18863/system/btrfs-impermanence.nix
https://github.com/ilkecan/config/blob/1ae5c7b74022deb39d1d33995898fb4c6f8e8302/nix/hosts/mephistopheles/impermanence.nix
*/

{ config, lib, ... }: 
let
    cfg = config.sys.disk.impermanence;
in {
    options.sys.disk.impermanence = {
        enable = lib.mkEnableOption "Impermanence";
        folder = lib.mkOption {
            type    = lib.types.str;
            default = "/persist";
            description = "Path to the persistent storage mountpoint";
        };
    };

    config = lib.mkIf cfg.enable {
        fileSystems = {
            ${cfg.folder}.neededForBoot = true;
            "/var/log".neededForBoot = true;
        };

        environment.persistence.${cfg.folder} = {
            hideMounts = true;
            directories = [
                "/var/log"
                "/var/lib/nixos"
                "/var/lib/systemd"
            ];
            files = [
                "/etc/machine-id"
                # Stable host identity across rollbacks. Also the sops-nix
                # decryption key -- must survive or secrets become unreadable.
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
                #"/var/lib/systemd/random-seed"
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
