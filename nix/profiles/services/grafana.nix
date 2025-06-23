{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.services.grafana;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.grafana.enable = mkEnableOption "Enable and set up grafana.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        # ───────────────────────── from wiki.nixos.org ─────────────────────────
        # https://wiki.nixos.org/wiki/Grafana
        # https://community.grafana.com/t/installing-on-nixos/6712
        # ───────────────────────────────────────────────────────────────────────

        services.grafana = {
            enable = true;
            settings = {
                server = {
                    # Listening Address and Port
                    http_addr = ""; # Listen (bind) to all network interfaces (i.e. 127.0.0.1, and ipAddress)
                    #http_addr = "127.0.0.1";
                    http_port = 3000;
                
                    # Grafana needs to know on which domain and URL it's running
                    #domain = "your.domain";
                    domain = "grafana.waifu";
                    #root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
                    #root_url = "https://grafana.waifu/"; # Not needed if it is `https://your.domain/`
                    #serve_from_sub_path = true;
                };
            };
        };

        services.nginx.virtualHosts."your.domain" = {
            addSSL = true;
            enableACME = true;
            locations."/" = {
                proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
                proxyWebsockets = true;
                recommendedProxySettings = true;
            };
        };

        # ------------------------ from xe.iaso ------------------------
        #services.grafana = {
            #enable = true;
            #settings.server = {
                #domain = "grafana.waifu";
                #http_port = 2342;
                #http_addr = "127.0.0.1";
            #};
        #};

        #services.nginx.virtualHosts.${config.services.grafana.domain} = {
            #locations."/" = {
                #proxyPass = "http:127.0.0.1:${toString config.services.grafana.port}";
                #proxyWebsockets = true;
            #};
        #};
    };
}


