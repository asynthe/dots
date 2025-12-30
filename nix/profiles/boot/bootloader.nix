# TODO What's boot.bootspec.enable = true; ?
# TODO Silent: TEST
# TODO Secure
# See what files to persist?

{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.boot.bootloader;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.boot.bootloader = {
        secure = mkEnableOption "Enable Secure Boot for current system."; 
        silent = mkEnableOption "Enable configuration for a Silent Boot (almost possible, because of nix stages output at boot).";
        type = mkOption {
            type = enum [ "grub" "refind" "systemd-boot" ];
            default = "systemd-boot";
            description = "System boot loader.";
        };

        generations = mkOption {
            type = int;
            default = 3;
            description = "Number of generations to output.";
        };
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkMerge [

        # Shared configuration
        {
            boot.loader.efi.canTouchEfiVariables = true;
        }

        # Grub
        (mkIf (cfg.type == "grub") { 
            boot.loader = {
                # ...
            };
        })

        # systemd-boot
        (mkIf (cfg.type == "systemd-boot") { 
            boot.loader = {
                timeout = null;
                systemd-boot.enable = true;
                systemd-boot.configurationLimit = cfg.generations;
            };
        })

        # rEFInd
        (mkIf (cfg.type == "refind") { 
            boot.loader = {
                # ...
            };
        })

        # Silent Boot
        (mkIf cfg.silent {
            boot = {
                consoleLogLevel = 0;
                initrd.verbose = false;
                kernelParams = [
                    "quiet"
                    "splash"
                    "vga=current"
                    "rd.systemd.show_status=false"
                    "rd.udev.log_level=3"
                    "udev.log_priority=3"
                    #"rd.udev.log_priority=3"
                    #"boot.shell_on_fail"
                    #"button.lid_init_state=open"
                    #"log_level=3"
                ];
            };
        })

        (mkIf cfg.secure {
            # -------------- Secure Boot --------------
            # https://wiki.nixos.org/wiki/Secure_Boot
            # https://github.com/nix-community/lanzaboote

            # Process
            # 1. Disable Secure Boot, 
            # `nix-shell -p sbctl`
            # `sudo sbctl create-keys`
            # Rebuild system with option on.
            # `sudo sbctl verify` to do final check.
            #
            # 2. Enable Secure Boot and boot into NixOS
            # Enroll keys with `sudo sbctl enroll-keys --microsoft`

            # -------------- Lanzaboote --------------
            # Lanzaboote currently replaces the systemd-boot module.
            # This setting is usually set to true in configuration.nix
            # generated at installation time. So we force it to false
            # for now.
            boot.loader.systemd-boot.enable = mkForce false;
            boot.lanzaboote = {
                enable = true;
                pkiBundle = "/etc/secureboot";
            };

            # For debugging and troubleshooting Secure Boot.
            environment.systemPackages = with pkgs; [ sbctl ];

            # -------------- Persistence --------------
            environment.persistence."/persist".directories = mkIf config.meta.disk.persistence.enable [
                config.boot.lanzaboote.pkiBundle  
            ];
        })
    ];
}
