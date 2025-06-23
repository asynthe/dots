# TODO
# Configure `config.meta.services.qbittorrent-nox.port`.

{ config, lib, pkgs, ... }:
with lib; with types; 
let
    cfg = config.meta.services.qbittorrent-nox;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.qbittorrent-nox = {
        enable = mkEnableOption "Set up the qBittorrent-nox daemon.";
        persistence = mkOption {
            type = bool;
            default = false;
            description = "Sets up persistence for qBittorrent configuration files.";
        };
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        environment.systemPackages = with pkgs; [ qbittorrent-nox ];

	    # See the logs by running.
        # journalctl -u qbittorrent-nox.service

        # ADD persistence option.
        #environment.persistence."/persist".directories = mkIf cfg.persist [
            #{
                #directory = "${cfg.dataDir}";
                #user = "${cfg.user}";
                #group = "${cfg.group}";
                #mode = "0750";
            #}
        #];

        #networking.firewall = {
            #allowedTCPPorts = [ 8080 ];
            #allowedUDPPorts = [ 8080 ];
        #};

        #systemd.user.services.qbittorrent-nox = {
            #description = "qBittorrent-nox service";
            #path = [ pkgs.qbittorrent-nox ];
            #after = [ "network.target" ];
            #wantedBy = [ "default.target" "multi-user.target" ];
            #serviceConfig = {
                #Type = "simple";
                #ExecStart = ''
                  #${pkgs.qbittorrent-nox}/bin/qbittorrent-nox
                #'';
            #};
        #};
    };
}
