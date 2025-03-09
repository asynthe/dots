{
    services.ollama = {
        enable = true;
        acceleration = "cuda";
        #environmentVariables = { OLLAMA_LLM_LIBRARY = "cpu"; };
        #package = ...;
        #listenAddress = ...; # default 11434
        #home = mkIf meta.system.persistence "/persist/ollama"
        #else ; # default "%S/ollama/models"
    };
}
