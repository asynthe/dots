{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.git;
in {
    options.sys.modules.git = {
        enable = lib.mkEnableOption "Git";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            git
            git-lfs
            bfg-repo-cleaner
            jujutsu
        ];
    };
}
