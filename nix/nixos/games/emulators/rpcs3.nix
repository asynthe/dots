{ ... }:
{
    flake.modules.nixos.rpcs3 = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ rpcs3 ];
    };
}
