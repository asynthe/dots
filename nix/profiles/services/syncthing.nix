# TODO
# configure `config.meta.services.syncthing.port`

{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.syncthing;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.syncthing.enable = mkEnableOption "Enable and set up Syncthing.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        environment.systemPackages = with pkgs; [
            syncthing
            syncthingtray
            stc-cli
        ];

        # Enable and configure.
        #services.syncthing = {
            #enable = true;
            #systemService = true; # Run as system service.
            #user = "${user}";
            #package = ;
            #group = ""; Group to run Syncthing under, default 'syncthing'.
            #extraFlags = ;
            #devices = ;
            #dataDir = "";

            # Shared folders.
            #folders = ;
        #};

        #services.syncthing.relay = {
            #enable = true;
            #port = ; default `22067`. Needs to be added to networking.firewall.allowedTCPPorts
        #};

        #networking.firewall.allowedTCPPorts = config.services.syncthing.relay.port;
    };
}
