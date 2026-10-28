_: {
  flake.modules.nixos.xenia = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ xenia-canary ];
  };
}
