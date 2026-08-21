{ config, lib, pkgs, ... }:
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
        exec ${ragEnv}/bin/python ${./rag.py} "$@"
    '';
in {
    environment.systemPackages = [
        ragScript
        pkgs.ollama
        pkgs.fabric-ai
    ];

    services.ollama = {
        enable = true;
        paclages = pkgs.ollama-cuda;
    };
}
