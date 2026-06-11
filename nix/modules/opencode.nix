{ config, lib, pkgs, ... }:
    let
    cfg = config.sys.modules.opencode;
in {
    options.sys.modules.opencode = {
        enable = lib.mkEnableOption "opencode";
    };

    config = lib.mkIf cfg.enable {

        # TODO This will enable ollama
        # Ollama will check what configuration

        # ASSERTIONS
        # - Set up nvidia or intel in the custom configuration 
        # - If both, prefer nvidia over intel

        environment.systemPackages = with pkgs; [
            opencode
        ];

        # Ollama and agent to test
        services.ollama = {
            enable = true;
            package = pkgs.ollama-cuda; # If meta.gpu.nvidia.true else disable (?)
            #port = 11434 # default
            syncModels = true;
            loadModels = [ 
                "qwen3-coder:30b"
                #"qwen3:14b" # fast on CPU
                #"qwen3:30b" # better quality, slower
            ];
        };
    };
}
