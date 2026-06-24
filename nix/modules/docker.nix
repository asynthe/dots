{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.docker;
in {
    options.sys.modules.docker = {
        enable = lib.mkEnableOption "Docker";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.docker.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "docker" ];
        # TODO Option like sys.system.filesystem = "btrfs"
        virtualisation.docker.storageDriver = "btrfs";
    };
}
