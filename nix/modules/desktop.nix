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

        autologin = {
            enable = lib.mkEnableOption "passwordless getty login on tty1";
            user   = lib.mkOption {
                type        = lib.types.str;
                description = "User to autologin as";
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
            programs.hyprland = {
                enable   = true;
                withUWSM = true;
            };

            # Was `systemctl --user enable` in .zprofile, unreachable after exec.
            systemd.packages = [ pkgs.hyprpolkitagent ];
            systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

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
                kitty
                warp-terminal
                wezterm

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

        # No display manager: getty logs in on tty1 and zsh's .zprofile hands
        # off to `uwsm start`. Quitting Hyprland returns to that shell.
        (lib.mkIf cfg.autologin.enable {
            services.getty.autologinUser = cfg.autologin.user;
            # First tty only, once per boot -- tty2-6 still prompt, so this is
            # no looser than greetd's autologin was.
            services.getty.autologinOnce = true;
        })
    ];
}
