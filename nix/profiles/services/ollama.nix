{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.services.ollama;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.ollama.enable = mkEnableOption "Enable and set up Ollama.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.ollama = {
            enable = true;
            acceleration = "cuda";
            #environmentVariables = { OLLAMA_LLM_LIBRARY = "cpu"; };
            #package = ...;
            #listenAddress = ...; # default 11434
            #home = mkIf meta.system.persistence "/persist/ollama"
            #else ; # default "%S/ollama/models"
        };
    };
}
