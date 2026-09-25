{ ... }:
{
    flake.modules.nixos.uzdoom = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            uzdoom
        ];
    };
}
