{ ... }:
{
    flake.modules.nixos.quickshell = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            quickshell
            qt6.qtdeclarative
        ];
    };
}
