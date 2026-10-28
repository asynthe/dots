_: {
  flake.modules.nixos.cemu = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ cemu ];
  };
}
