{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.gaming;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.gaming.gamemode = mkEnableOption "Enable Gamemode to get more performance in games.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.gamemode {

        # Better performance on games. Use with `gamemoderun`.
        users.users.${config.meta.system.user}.extraGroups = [ "gamemode" ];
        programs.gamemode = {
            enable = true;
	        enableRenice = true;
        };
    };
}
