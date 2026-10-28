_: {
  flake.modules.nixos.azahar = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ azahar ];
  };
}
