{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.sys.modules.gaming;
in {
    options.sys.modules.gaming = {
        enable = lib.mkEnableOption "Gaming";

        star-citizen = {
            enable = lib.mkEnableOption "Star Citizen";
            cache  = lib.mkEnableOption "Build caches for Star Citizen";
        };

        eden.enable     = lib.mkEnableOption "Eden Switch emulator";
        lutris.enable   = lib.mkEnableOption "Lutris launcher";
        pcsx2.enable    = lib.mkEnableOption "PCSX2 PS2 emulator";
        rpcs3.enable    = lib.mkEnableOption "RPCS3 PS3 emulator";
        ryubing.enable  = lib.mkEnableOption "Ryubing Switch emulator";
        xenia.enable    = lib.mkEnableOption "Xenia Xbox 360 emulator";
    };

    config = lib.mkMerge [
        (lib.mkIf cfg.star-citizen.cache {
            assertions = [{
                assertion = cfg.star-citizen.enable;
                message = "sys.modules.gaming: star-citizen.cache requires star-citizen.enable";
            }];
            nix.settings = {
                substituters      = [ "https://nix-citizen.cachix.org" ];
                trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
            };
        })

        (lib.mkIf cfg.star-citizen.enable {
            environment.systemPackages = [
                inputs.nix-citizen.packages.${pkgs.system}.rsi-launcher
            ];
        })

        (lib.mkIf cfg.eden.enable {
            environment.systemPackages = with pkgs; [ eden ];
        })

        (lib.mkIf cfg.lutris.enable {
            environment.systemPackages = with pkgs; [ lutris ];
        })

        (lib.mkIf cfg.pcsx2.enable {
            environment.systemPackages = with pkgs; [ pcsx2 ];
        })

        (lib.mkIf cfg.rpcs3.enable {
            environment.systemPackages = with pkgs; [ rpcs3 ];
        })

        (lib.mkIf cfg.ryubing.enable {
            environment.systemPackages = with pkgs; [ ryubing ];
        })

        (lib.mkIf cfg.xenia.enable {
            environment.systemPackages = with pkgs; [ xenia-canary ];
        })
    ];
}
