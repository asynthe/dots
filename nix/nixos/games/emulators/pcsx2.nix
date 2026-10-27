{ ... }:
{
    flake.modules.nixos.pcsx2 = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ pcsx2 ];
    };
}
