{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.vscodium;
in {
    options.sys.modules.vscodium = {
        enable = lib.mkEnableOption "VSCodium";
    };

    config = lib.mkIf cfg.enable {
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
}
