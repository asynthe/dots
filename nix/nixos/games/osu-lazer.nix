{ ... }:
{
    flake.modules.nixos.osu-lazer = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            osu-lazer #osu-lazer-bin
        ];
    };
}
