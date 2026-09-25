{ ... }:
{
    flake.modules.nixos.qbittorrent = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ qbittorrent ];
    };
}
