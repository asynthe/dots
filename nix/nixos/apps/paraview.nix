{ ... }:
{
    flake.modules.nixos.paraview = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ paraview ];
    };
}
