{ ... }:
{
    flake.modules.nixos.colord = { ... }: {
        services.colord.enable = true;
    };
}
