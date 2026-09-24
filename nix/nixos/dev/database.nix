{ ... }:
{
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

    flake.modules.nixos.database-gui = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            dbeaver-bin
        ];
    };

    flake.modules.nixos.postgres-local = { config, lib, pkgs, ... }: {
        services.postgresql = {
            enable = true;
            package = pkgs.postgresql_17;
            ensureDatabases = [ "play" ];
            ensureUsers = [{
                name = config.sys.user;
                ensureClauses.superuser = true;
            }];
            authentication = lib.mkForce ''
                local all all              trust
                host  all all 127.0.0.1/32 trust
                host  all all ::1/128      trust
            '';
        };

        environment.persistence = lib.mkIf config.sys.impermanence.enable {
            ${config.sys.impermanence.folder}.directories = [ "/var/lib/postgresql" ];
        };
    };
}
