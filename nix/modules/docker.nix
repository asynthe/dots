{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.docker;
in {
    options.sys.modules.docker = {
        enable = lib.mkEnableOption "Docker";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.docker.enable = true;
        # TODO Refer option like sys.username = "meow"
        users.users.meow.extraGroups = [ "docker" ]; # TODO Change user
        # TODO Option like sys.system.filesystem = "btrfs"
        virtualisation.docker.storageDriver = "btrfs";
    };
}
