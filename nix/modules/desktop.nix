{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.sys.modules.desktop;
in {
    options.sys.modules.desktop = {
        hyprland = {
            enable = lib.mkEnableOption "Hyprland compositor";
            flake  = lib.mkEnableOption "Use the Hyprland flake instead of nixpkgs";
            cache  = lib.mkEnableOption "Build caches for Hyprland (requires flake)";
        };

        greetd = {
            enable    = lib.mkEnableOption "greetd display manager";
            autologin = {
                enable = lib.mkEnableOption "autologin into Hyprland, falling back to tuigreet on failure";
                user   = lib.mkOption {
                    type        = lib.types.str;
                    description = "User to autologin as";
                };
            };
        };
    };

    config = lib.mkMerge [
        (lib.mkIf cfg.hyprland.cache {
            assertions = [{
                assertion = cfg.hyprland.flake;
                message   = "sys.modules.desktop: hyprland.cache requires hyprland.flake";
            }];
            nix.settings = {
                substituters      = [ "https://hyprland.cachix.org" ];
                trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
            };
        })

        (lib.mkIf (cfg.hyprland.enable && cfg.hyprland.flake) {
            programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        })

        (lib.mkIf cfg.hyprland.enable {
            services.displayManager.defaultSession = "hyprland-uwsm";
            programs.hyprland = {
                enable   = true;
                withUWSM = true;
            };

            systemd.user.services."hyprland-dpms-resume" = {
                description = "Re-enable Hyprland displays after resume";
                after    = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
                wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
                serviceConfig = {
                    Type         = "oneshot";
                    ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
                    ExecStart    = "${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
                };
            };

            environment.systemPackages = with pkgs; [

                # Apps
                brightnessctl
                fuzzel rofi 
                walker elephant
                gromit-mpx
                hypridle
                hyprshot
                imv
                mako libnotify
                playerctl
                ripdrag
                socat
                wl-clipboard

                # Libs
                hyprpolkitagent
                adw-gtk3

                # Terminals
                alacritty
                ghostty
                wezterm
                kitty

                # GUI
                pavucontrol
                firefox arkenfox-userjs dejsonlz4
                #librewolf #mullvad-browser 
                ungoogled-chromium
                mpv
                tidal-hifi
                webcord
                awww
                mpvpaper
                waypaper
                waybar
                zathura sioyek
            ];
        })

        (lib.mkIf cfg.greetd.enable {
            services.greetd = {
                enable        = true;
                useTextGreeter = true;
                settings = {
                    default_session.command = lib.concatStringsSep " " [
                        "${pkgs.tuigreet}/bin/tuigreet"
                        "--remember"
                        "--asterisks"
                        "--cmd"
                        "'uwsm start hyprland-uwsm.desktop'"
                    ];
                } // lib.optionalAttrs cfg.greetd.autologin.enable {
                    initial_session = {
                        command = "uwsm start hyprland-uwsm.desktop";
                        user    = cfg.greetd.autologin.user;
                    };
                };
            };
        })
    ];
}
