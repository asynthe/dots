{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.sys.modules.gaming;

    rpcs3-bin = pkgs.appimageTools.wrapType2 {
        pname   = "rpcs3";
        version = "0.0.41-19515-a7fc31f3";
        src     = pkgs.fetchurl {
            url    = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-a7fc31f3212c55bf0b70b45875c52dfc94f6641a/rpcs3-v0.0.41-19515-a7fc31f3_linux64.AppImage";
            sha256 = "1jbldny7k2qx4apbp9nd9m4j79w5pgdzykb47wsc80rzav0xsxaw";
        };
    };
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
        rpcs3.enable    = lib.mkEnableOption "RPCS3 PS3 emulator (binary)";
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
            assertions = [{
                assertion = pkgs.stdenv.hostPlatform.isx86_64 && pkgs.stdenv.hostPlatform.isLinux;
                message   = "sys.modules.gaming: rpcs3 AppImage is only available for x86_64-linux";
            }];
            environment.systemPackages = [ rpcs3-bin ];
        })

        (lib.mkIf cfg.ryubing.enable {
            environment.systemPackages = with pkgs; [ ryubing ];
        })

        (lib.mkIf cfg.xenia.enable {
            environment.systemPackages = with pkgs; [ xenia-canary ];
        })
    ];
}
