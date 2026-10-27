{ ... }:
{
    flake.modules.nixos.opencode = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.opencode ];
    };
}
