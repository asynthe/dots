{ ... }:
{
    flake.modules.nixos.dolphin = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ dolphin-emu ];
    };
}
