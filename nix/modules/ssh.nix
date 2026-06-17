{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.ssh;
    impermanenceCfg = config.sys.modules.impermanence;
in {
    options.sys.modules.ssh = {
        enable = lib.mkEnableOption "SSH";
    };

    config = lib.mkIf cfg.enable {
        services.openssh.enable = true;
    };
}
