# TODO
# - Assertion of 'if a backend is selected, enable must be true'
# - Add list of multiple backends: services.sql.backend = [ "mysql" "postgresql" ]; # mysql, postgresql or both

{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.sql;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.sql.enable = mkEnableOption "Enable and set up an SQL Server and editors.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.mysql = {
	        enable = true;
	        package = pkgs.mariadb;
        };

        environment.systemPackages = with pkgs; [
            pgadmin4
            pgmanage # Now called postage.
            dbeaver
        ];
    };
}
