{ pkgs, ... }: {

    programs.vscode.extensions = with pkgs.vscode-extensions; [
        asvetliakov.vscode-neovim
        bbenoist.nix
        eamodio.gitlens
        ms-azuretools.vscode-docker
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-ssh
        sumneko.lua
        #vscodevim.vim
    ];
}
