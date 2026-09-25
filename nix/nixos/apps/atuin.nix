{ ... }:
{
    flake.modules.nixos.atuin = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ atuin ];
    };
}
