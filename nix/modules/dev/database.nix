_: {
  flake.modules.nixos.database = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      duckdb
      sqlite
      harlequin
      pgcli
      litecli
      usql

      sqlfluff
    ];
  };
}
