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

    flake.modules.nixos.dbt = { pkgs, ... }: let
        # nixpkgs-unstable ships pathspec 1.1.x, but dbt-common pins
        # pathspec<1.1 -- the bound is stale, so relax it. Top-level `dbt` is
        # `toPythonApplication dbt-core` on python3Packages (3.14), where
        # dbt-semantic-interfaces is unsupported, hence pinning to 3.13.
        python = pkgs.python313.override {
            packageOverrides = _: super: {
                dbt-common = super.dbt-common.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "pathspec" ];
                });
            };
        };

        # withAdapters, not python.withPackages -- the adapters are namespace
        # packages and collide on dbt/__init__.py in a plain buildEnv.
        dbt-env = (python.pkgs.toPythonApplication python.pkgs.dbt-core)
            .withAdapters (ps: [ ps.dbt-postgres ]);
    in {
        # Expose only bin/dbt; the env also carries bin/python3, which would
        # collide with the python aspect in lang.nix.
        environment.systemPackages = [
            (pkgs.runCommand "dbt" { } ''
                mkdir -p $out/bin
                ln -s ${dbt-env}/bin/dbt $out/bin/dbt
            '')
        ];
    };
}
