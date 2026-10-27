{ ... }:
{
    flake.modules.nixos.hhkb = { ... }: {
        services.keyd = {
            enable = true;
            keyboards.hhkb = {
                ids = [ "04fe:0021" ];
                settings.main = {
                    muhenkan = "leftmeta";
                    henkan = "rightmeta";
                };
            };
        };
    };
}
