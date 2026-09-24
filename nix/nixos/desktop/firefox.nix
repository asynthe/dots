{ ... }:
{
    flake.modules.nixos.firefox-clean = { config, pkgs, ... }: {

        systemd.user.services.firefox-clean = {
            description = "Drop non-container Firefox cookies and site storage";
            wantedBy    = [ "graphical-session-pre.target" ];
            before      = [ "graphical-session.target" ];

            path = with pkgs; [ bash sqlite procps coreutils gnugrep gnused ];

            serviceConfig = {
                Type      = "oneshot";
                ExecStart = "${config.sys.flake}/scripts/firefox_clean.sh --apply";

                SuccessExitStatus = [ 0 1 ];
            };
        };

        environment.systemPackages = [ pkgs.sqlite ];
    };
}
