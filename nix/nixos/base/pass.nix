{ ... }:
{
    flake.modules.nixos.pass = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.pass-wayland ];
    };
}
