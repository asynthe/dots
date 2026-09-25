{ ... }:
{
    flake.modules.nixos.codex = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.codex ];
    };
}
