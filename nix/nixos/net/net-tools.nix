{ ... }:
{
    flake.modules.nixos.net-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bandwhich
            nethogs
            speedtest-cli
        ];
    };
}
