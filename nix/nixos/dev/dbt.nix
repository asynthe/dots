{ ... }:
{
    flake.modules.nixos.dbt = { pkgs, ... }: let
        # 3.13: dbt-semantic-interfaces doesn't support 3.14. Relaxed pins are stale bounds.
        python = pkgs.python313.override {
            packageOverrides = _: super: {
                dbt-common = super.dbt-common.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "pathspec" ];
                });
                dbt-semantic-interfaces = super.dbt-semantic-interfaces.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "click" ];
                });
                dbt-core = super.dbt-core.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "click" ];
                });
            };
        };

        # withAdapters: the adapters are namespace packages and collide in a buildEnv.
        dbt-env = (python.pkgs.toPythonApplication python.pkgs.dbt-core)
            .withAdapters (ps: [ ps.dbt-postgres ]);
    in {
        # Only bin/dbt, so the env's python3 doesn't shadow the system one.
        environment.systemPackages = [
            (pkgs.runCommand "dbt" { } ''
                mkdir -p $out/bin
                ln -s ${dbt-env}/bin/dbt $out/bin/dbt
            '')
        ];
    };
}
