{ ... }:
{
    flake.modules.nixos.ryubing = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ ryubing ];
    };
}
