{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.services.docker.containers;
    dockerEnabled = config.meta.services.docker.enable;    
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.docker.containers.monica = {
        enable = mkEnableOption "Enable and set up Monica (container).";
        dir = mkOption {
            type = types.str;
            default = "/mnt/data/monica";
            description = "Directory to store Monica data and mySQL data.";
        };
    };
    options.meta.services.docker.containers.prowlarr.enable = mkEnableOption "Enable and set up Prowlarr (container).";
    options.meta.services.docker.containers.radarr.enable = mkEnableOption "Enable and set up Radarr (container).";
    options.meta.services.docker.containers.sonarr.enable = mkEnableOption "Enable and set up Sonarr (container).";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf dockerEnabled {
        virtualisation.oci-containers = {
            backend = "docker";
            containers =  mkMerge [

                # ───────────────────────── Monica ─────────────────────────
                (mkIf cfg.monica.enable {
                    # MySQL for Monica
                    monica-mysql = {
                        image = "mysql:5.7";
                        environment = {
                            MYSQL_RANDOM_ROOT_PASSWORD = "true";
                            MYSQL_DATABASE = "monica";
                            MYSQL_USER = "meow";
                            MYSQL_PASSWORD = "secret";
                        };
                        volumes = [
                            #"/mnt/sda1/monica/mysql:/var/lib/mysql"
                            #"/tmp/monica/mysql:/var/lib/mysql"
                            "${cfg.monica.dir}/mysql:/var/lib/mysql"
                        ];
                        extraOptions = [ "--network=monica-network" ];
                    };
                    # Monica CRM
                    monica = {
                        image = "monica";
                        environment = {
                            DB_HOST = "monica-mysql";
                            DB_DATABASE = "monica";
                            DB_USERNAME = "meow";
                            DB_PASSWORD = "secret";
                        };
                        ports = [ "8081:80" ];
                        volumes = [
                            #"/mnt/monica/storage:/var/www/html/storage"
                            #"/tmp/monica/storage:/var/www/html/storage"
                            "${cfg.monica.dir}/storage:/var/www/html/storage"
                        ];
                        extraOptions = [ "--network=monica-network" ];
                    };
                })

                # ───────────────────────── Prowlarr ─────────────────────────
                (mkIf cfg.prowlarr.enable {
                    prowlarr = {
                        image = "linuxserver/prowlarr:latest";
                        environment = {
                            PUID = "1000";
                            PGID = "1000";
                            TZ = "${config.time.timeZone}";
                        };
                        volumes = [
                            "/mnt/sda1/prowlarr/config:/config"
                        ];
                        extraOptions = [ "--network=host" ];
                    };
                })

                # ───────────────────────── Sonarr ─────────────────────────
                (mkIf cfg.sonarr.enable {
                    sonarr = {
                        image = "linuxserver/sonarr:latest";
                        environment = {
                            PUID = "1000";
                            PGID = "1000";
                            TZ = "${config.time.timeZone}";
                        };
                        volumes = [
                            "/mnt/sda1/sonarr/config:/config"
                            "/mnt/sda1/media:/media"
                            "/mnt/sda1/data/torrents:/downloads"
                        ];
                        extraOptions = [ "--network=host" ];
                    };
                })

                # ───────────────────────── Radarr ─────────────────────────
                (mkIf cfg.radarr.enable {
                    radarr = {
                        image = "linuxserver/radarr:latest";
                        environment = {
                            PUID = "1000";
                            PGID = "1000";
                            TZ = "${config.time.timeZone}";
                        };
                        volumes = [
                            "/mnt/sda1/radarr/config:/config"
                            "/mnt/sda1/media:/media"
                            "/mnt/sda1/data/torrents:/downloads"
                        ];
                        extraOptions = [ "--network=host" ];
                    };
                })
            ];
        };

        # ───────────────────────── Systemd services ─────────────────────────
        # Monica
        systemd.services.init-monica-network = mkIf cfg.monica.enable {
            description = "Create monica-network";
            wantedBy = [ "multi-user.target" ];
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.runtimeShell} -c '${pkgs.docker}/bin/docker network inspect monica-network >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create monica-network'";
            };
        };
    };
}
