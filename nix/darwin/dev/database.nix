{ ... }:
{
    # Same list as nix/nixos/dev/database.nix's `database` aspect, minus
    # `database-gui` (dbeaver-bin is flaky on darwin -- a cask fits better)
    # and `postgres-local` (services.postgresql is NixOS-only; nix.enable is
    # false here, so no daemon management on this host at all).
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
