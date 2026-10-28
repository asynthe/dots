_: {
  flake.modules.nixos.net-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      bandwhich
      bmon
      nethogs
      speedtest-cli
    ];
  };
}
