_: {
  flake.modules.nixos.work = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      code-cursor
      postman
      teams-for-linux
    ];
  };
}
