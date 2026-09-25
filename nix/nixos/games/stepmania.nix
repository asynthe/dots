{ ... }:
{
    flake.modules.nixos.stepmania = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            stepmania
        ];
    };
}
