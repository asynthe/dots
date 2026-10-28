_: {
  flake.modules.nixos.hhkb = _: {
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
