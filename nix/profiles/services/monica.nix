{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.monica;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.monica.enable = mkEnableOption "Enable and set up Monica.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.monica.enable = true;

        # TODO file with a random string used as a Key
        #services.monica.appKeyFile = ...
        #services.monica = {
        #    enable = true;
        #    hostname = "monica.asynthe.jp";
        #    appURL = "https://monica.asynthe.jp";
        #    appKeyFile = "/home/meow/monica/monicafile";
        #    nginx = {
        #        serverName = "monica.asynthe.jp";
        #        serverAliases = [
        #            "monica.asynthe.jp"
        #        ];
        #        enableACME = true;
        #        forceSSL = true;
        #    };
        #};
    };
}
