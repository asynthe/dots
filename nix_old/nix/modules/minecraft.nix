{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.minecraft;
in {
    options.sys.modules.minecraft = {
        enable = lib.mkEnableOption "Minecraft";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            fabric-installer
            optifine
            prismlauncher
        ];

        services.minecraft-server = {
            enable = true;
            eula = true;
            package = pkgs.papermc;
        };
    };
}
