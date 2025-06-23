{ config, lib, pkgs-stable, ... }:
with lib; 

# Once running for the first time, you can see the generated password with
# journalctl -u qbittorrent-nox.service

let
    cfg = config.services.qbittorrent-nox;
    configDir = "${cfg.dataDir}/.config";
    openFilesLimit = 4096;
in {
    options.services.qbittorrent-nox = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Set up the qBittorrent-nox daemon.
            '';
        };

        noPassword = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Disable password login for Tailscale.
            '';
        };

        persist = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Add persistence to the qBittorrent-nox directory.
            '';
        };

        dataDir = mkOption {
            type = types.path;
            default = "/var/lib/qbittorrent";
            description = ''
              Directory where qBittorrent-nox will create files.
            '';
        };

        user = mkOption {
            type = types.str;
            default = "qbittorrent";
            description = ''
              User under which qBittorrent runs.
            '';
        };

        group = mkOption {
            type = types.str;
            default = "qbittorrent";
            description = ''
              Group under which qBittorrent runs.
            '';
        };

        port = mkOption {
            type = types.port;
            default = 8080;
            description = ''
              qBittorrent-nox web UI port.
            '';
        };

        openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Open services.qbittorrent-nox.port to the outside network.
            '';
        };

        openFilesLimit = mkOption {
            default = openFilesLimit;
            description = ''
              Number of files to allow qBittorrent to open.
            '';
        };
    };

    config = mkIf cfg.enable {

        environment.persistence."/persist".directories = mkIf cfg.persist [
            {
                directory = "${cfg.dataDir}";
                user = "${cfg.user}";
                group = "${cfg.group}";
                mode = "0750";
            }
        ];

        networking.firewall = mkIf cfg.openFirewall {
            allowedTCPPorts = [ cfg.port ];
            allowedUDPPorts = [ cfg.port ];
        };

        systemd.tmpfiles.rules = [
            "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
        ];

        systemd.services.qbittorrent-nox = {
            description = "qBittorrent-nox service";
            path = [ pkgs-stable.qbittorrent ];
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target"];
            serviceConfig = {
                ExecStart = ''
                  ${pkgs-stable.qbittorrent-nox}/bin/qbittorrent-nox \
                    --profile=${configDir} \
                    --webui-port=${toString cfg.port}
                '';

                # Managed by systemd if quitted and shutdown.
                Restart = "on-success";
                User = cfg.user;
                Group = cfg.group;
                #UMask = "0002";
                #LimitNOFILE = cfg.openFilesLimit;
            };
        };

        users.users = mkIf (cfg.user == "qbittorrent") {
            qbittorrent = {
                description = "qBittorrent Daemon user";
                group = cfg.group;
                home = cfg.dataDir;
                isSystemUser = true;
            };
        };

        users.groups = mkIf (cfg.group == "qbittorrent") {
            qbittorrent = { gid = null; };
        };
    };
}
