{ ... }:
{
    flake.modules.nixos.claude-code = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.claude-code ];
    };

    flake.modules.nixos.opencode = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.opencode ];
    };

    flake.modules.nixos.fabric = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.fabric-ai ];
    };

    flake.modules.nixos.openclaw = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.openclaw ];
    };

    flake.modules.nixos.hermes = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ ];
    };

    flake.modules.nixos.ollama = { config, lib, pkgs, ... }: {
        options.sys.ollama = {
            cuda = lib.mkEnableOption "CUDA-accelerated Ollama (needs the nvidia-prime aspect)";
            models = lib.mkOption {
                type        = lib.types.listOf lib.types.str;
                default     = [];
                description = "Models to preload on startup";
            };
        };

        config.services.ollama = {
            enable     = true;
            package    = if config.sys.ollama.cuda then pkgs.ollama-cuda else pkgs.ollama;
            syncModels = true;
            loadModels = config.sys.ollama.models;
        };
    };

    # RAG CLI (LlamaIndex + ChromaDB via Ollama). Needs `ollama` alongside it.
    # NOTE: expects modules/nixos/rag/rag.py, which does not exist yet -- the
    # aspect is here for parity with the old tree but is not host-ready.
    flake.modules.nixos.rag = { pkgs, ... }:
    let
        ragEnv = pkgs.python3.withPackages (ps: with ps; [
            llama-index
            llama-index-core
            llama-index-embeddings-ollama
            llama-index-llms-ollama
            llama-index-vector-stores-chroma
            chromadb
            pypdf
        ]);

        ragScript = pkgs.writeShellScriptBin "rag" ''
            exec ${ragEnv}/bin/python ${./rag/rag.py} "$@"
        '';
    in {
        environment.systemPackages = [ ragScript ];
    };
}
