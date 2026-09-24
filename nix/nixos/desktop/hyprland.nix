{ inputs, ... }:
{
    flake.modules.nixos.hyprland = { pkgs, ... }: {
        programs.hyprland = {
            enable   = true;
            withUWSM = true;
        };

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

            brightnessctl
            fuzzel rofi
            walker elephant
            gromit-mpx
            hypridle
            hyprshot
            mako libnotify
            playerctl
            ripdrag
            socat
            wl-clipboard

            awww waypaper
            linux-wallpaperengine

            hyprpolkitagent
            adw-gtk3
        ];
    };

    flake.modules.nixos.hyprglass = { config, lib, pkgs, ... }: {
        environment.systemPackages = [
            (pkgs.hyprlandPlugins.mkHyprlandPlugin (final: {
                pluginName = "hyprglass";
                version    = "0.7.0";
                hyprland   = config.programs.hyprland.package;

                src = pkgs.fetchFromGitHub {
                    owner = "hyprnux";
                    repo  = "hyprglass";
                    tag   = "v${final.version}";
                    hash  = "sha256-x/584kY+XXlU/OWKtZAFo89VtowjLXs1DiP9PC0o0Os=";
                };

                installPhase = ''
                    runHook preInstall
                    install -Dm755 hyprglass.so $out/lib/libhyprglass.so
                    runHook postInstall
                '';

                meta = {
                    description = "Liquid Glass effect for Hyprland";
                    homepage    = "https://github.com/hyprnux/hyprglass";
                    license     = lib.licenses.bsd3;
                    platforms   = lib.platforms.linux;
                };
            }))
        ];
    };

    flake.modules.nixos.hyprland-flake = { pkgs, ... }: {
        programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    flake.modules.nixos.hyprland-cache = { ... }: {
        nix.settings = {
            substituters        = [ "https://hyprland.cachix.org" ];
            trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
        };
    };

    flake.modules.nixos.autologin = { config, ... }: {
        services.getty.autologinUser = config.sys.user;
        services.getty.autologinOnce = true;
    };
}
