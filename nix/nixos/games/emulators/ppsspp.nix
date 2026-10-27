{ ... }:
{
    flake.modules.nixos.ppsspp = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ ppsspp ];
    };
}
