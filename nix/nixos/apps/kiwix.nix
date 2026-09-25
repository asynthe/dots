{ ... }:
{
    flake.modules.nixos.kiwix = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ kiwix ];
    };
}
