{ inputs, ... }:
{
    flake.modules.nixos.hyprland = { pkgs, ... }: {
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
        ];
    };

    # Track the Hyprland flake instead of nixpkgs. Import alongside `hyprland`.
    flake.modules.nixos.hyprland-flake = { pkgs, ... }: {
        programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # Only useful with `hyprland-flake`; pointless against nixpkgs Hyprland.
    flake.modules.nixos.hyprland-cache = { ... }: {
        nix.settings = {
            substituters        = [ "https://hyprland.cachix.org" ];
            trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
        };
    };

    # No display manager: getty logs in on tty1 and zsh's .zprofile hands
    # off to `uwsm start`. Quitting Hyprland returns to that shell.
    flake.modules.nixos.autologin = { config, ... }: {
        services.getty.autologinUser = config.sys.user;
        # First tty only, once per boot -- tty2-6 still prompt, so this is
        # no looser than greetd's autologin was.
        services.getty.autologinOnce = true;
    };
}
