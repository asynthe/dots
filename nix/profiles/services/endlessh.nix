# TODO
# Set up port as the default or `config.meta.services.endlessh.port` if set.

{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.services.endlessh;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.endlessh.enable = mkEnableOption "Enable and set up Endlessh.";

    #options.services.endlessh.go = mkOption {
        #type = types.bool;
        #default = false;
        #description = ''
          #Enable and set up Endlessh go implementation.
        #'';
    #};

    #options.services.endlessh.port = mkOption {
        #type = types.port;
        #default = config.meta.service.port;
        #description = ''
          #Port to be used in Endlessh.
        #'';
    #};

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.endlessh-go = {
	        enable = true;
	        #port = cfg.port; # default `2222`.
	        #extraOptions = [ "-conn_type=tcp4" "-max_clients=8192" ];
	        #openFirewall = true;
	        #prometheus.listenAddress = ; # default `0.0.0.0`.
	        #prometheus.port = ; # default `2112`.
        };
            
        #services.endlessh = {
            #enable = true;
	        #port = 22; # default `2222`.
	        #extraOptions = [ "-6" "-d 9000" "-v" ];
	        #openFirewall = true; # default `false`.
        #};
    };
}
