{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.nvim;
in {
    options.sys.modules.nvim = {
        enable = lib.mkEnableOption "neovim";
    };

    config = lib.mkIf cfg.enable {

        environment.systemPackages = with pkgs; [
            neovim

            # core
            git
            gcc
            nodejs

            # search
            ripgrep
            fd

            # files
            yazi

            # lsp
            nixd
            bash-language-server
            pyright
            rust-analyzer
            typescript-language-server
            marksman

            # images
            imagemagick
        ];
    };
}
