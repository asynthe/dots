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
}
