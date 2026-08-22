{ ... }:
{
    flake.modules.nixos.net-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bandwhich
            nethogs
            speedtest-cli
        ];
    };

    flake.modules.nixos.soc-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            hping
            net-tools
            tcpdump
        ];
    };
}
