_: {
  flake.modules.nixos.osu-lazer = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      osu-lazer
    ];
  };
}
