{ ... }:
{
    flake.modules.nixos.net-tools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            nethogs
            bandwhich
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
