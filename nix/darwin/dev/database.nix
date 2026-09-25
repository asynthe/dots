{ ... }:
{
    flake.modules.darwin.database = { pkgs, ... }: {
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
