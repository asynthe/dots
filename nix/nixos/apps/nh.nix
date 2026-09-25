{ ... }:
{
    flake.modules.nixos.nh = { config, ... }: {
        programs.nh = {
            enable          = true;
            clean.enable    = true;
            clean.extraArgs = "--keep-since 4d --keep 3";
            flake           = config.sys.flake;
        };
    };
}
