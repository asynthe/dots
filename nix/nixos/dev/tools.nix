{ ... }:
{
    flake.modules.nixos.git = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            git
            git-lfs
            bfg-repo-cleaner
            jujutsu
        ];
    };

    flake.modules.nixos.neovim = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            neovim

            git
            gcc
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

            wl-clipboard

            imagemagick
        ];
    };

    flake.modules.nixos.terraform = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            opentofu
        ];
    };

    flake.modules.nixos.deploy-rs = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            deploy-rs
            ssh-to-age
        ];
    };

    flake.modules.nixos.vscodium = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            (vscode-with-extensions.override {
                vscode = vscodium;
                vscodeExtensions = with vscode-extensions; [
                    anthropic.claude-code
                    asvetliakov.vscode-neovim
                    bbenoist.nix
                    enkia.tokyo-night
                    mechatroner.rainbow-csv
                    ms-azuretools.vscode-docker
                    ms-python.python
                    ms-vscode-remote.remote-ssh
                    shd101wyy.markdown-preview-enhanced
                    yzhang.markdown-all-in-one
                    zhuangtongfa.material-theme
                ];
            })
        ];
    };

    flake.modules.nixos.web-dev = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bruno
            hugo
            p7zip
        ];
    };

    flake.modules.nixos.work = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            code-cursor
            postman
        ];
    };
}
