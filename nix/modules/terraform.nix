{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.terraform;
in {
    options.sys.modules.terraform = {
        enable = lib.mkEnableOption "Terraform";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            opentofu
        ];
    };
}
