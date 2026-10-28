_: {
  flake.modules.nixos.eden = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ eden ];
  };
}
