{ ... }:
{
    flake.modules.darwin.neovim = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            neovim

            nodejs

            ripgrep
            fd

            yazi

            nixd
            bash-language-server
            pyright
            rust-analyzer
            typescript-language-server
            marksman
            lua-language-server
            gopls
            vscode-langservers-extracted
            yaml-language-server

            stylua
            nixfmt
            ruff
            shfmt
            prettierd

            imagemagick
        ];
    };
}
