{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.ai;

    ragEnv = pkgs.python3.withPackages (ps: with ps; [
        llama-index
        llama-index-core
        llama-index-embeddings-ollama
        llama-index-llms-ollama
        llama-index-vector-stores-chroma
        chromadb
        pypdf
    ]);

    # rag.py must exist at nix/modules/rag/rag.py
    ragScript = pkgs.writeShellScriptBin "rag" ''
        exec ${ragEnv}/bin/python ${./rag/rag.py} "$@"
    '';
in {
    options.sys.modules.ai = {
        claude-code.enable = lib.mkEnableOption "Claude Code CLI";
        opencode.enable    = lib.mkEnableOption "OpenCode AI coding assistant";
        fabric.enable      = lib.mkEnableOption "Fabric AI CLI";

        ollama = {
            enable = lib.mkEnableOption "Ollama local LLM server";
            cuda   = lib.mkEnableOption "CUDA-accelerated Ollama (requires nvidia.enable)";
            models = lib.mkOption {
                type        = lib.types.listOf lib.types.str;
                default     = [];
                description = "Models to preload on startup";
            };
        };

        openclaw.enable = lib.mkEnableOption "OpenClaw";
        rag.enable      = lib.mkEnableOption "RAG CLI tool (LlamaIndex + ChromaDB via Ollama)";
    };

    config = lib.mkMerge [
        (lib.mkIf cfg.claude-code.enable {
            environment.systemPackages = [ pkgs.claude-code ];
        })

        (lib.mkIf cfg.opencode.enable {
            environment.systemPackages = [ pkgs.opencode ];
        })

        (lib.mkIf cfg.fabric.enable {
            environment.systemPackages = [ pkgs.fabric-ai ];
        })

        (lib.mkIf cfg.ollama.enable {
            services.ollama = {
                enable     = true;
                package    = if cfg.ollama.cuda then pkgs.ollama-cuda else pkgs.ollama;
                syncModels = true;
                loadModels = cfg.ollama.models;
            };
        })

        (lib.mkIf cfg.openclaw.enable {
            environment.systemPackages = [ pkgs.openclaw ];
        })

        (lib.mkIf cfg.rag.enable {
            environment.systemPackages = [ ragScript ];
        })
    ];
}
