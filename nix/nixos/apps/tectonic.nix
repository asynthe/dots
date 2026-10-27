{ ... }:
{
    flake.modules.nixos.tectonic = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ tectonic ];
    };
}
