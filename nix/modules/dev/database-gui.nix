_: {
  flake.modules.nixos.database-gui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      dbeaver-bin
    ];
  };
}
