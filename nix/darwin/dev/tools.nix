{ ... }:
{
    flake.modules.darwin.neovim = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            neovim

            # Xcode CLT already provides cc/clang/gcc and git -- nixpkgs gcc and
            # wl-clipboard (Wayland-only) from the NixOS neovim aspect don't
            # belong here.
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
