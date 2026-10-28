_: {
  # Copilot key -> F13, which hyprland.lua binds (docs/hyprland.md).
  flake.modules.nixos.copilot-key = _: {
    services.keyd = {
      enable = true;
      keyboards.copilot = {
        ids = [ "*" ];
        settings = {
          main.f23 = "f13";
          meta.f23 = "f13";
        };
      };
    };
  };
}
