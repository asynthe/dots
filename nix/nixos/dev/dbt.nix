{ ... }:
{
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
                # pins click<8.4; nixpkgs ships 8.4.x
                dbt-semantic-interfaces = super.dbt-semantic-interfaces.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "click" ];
                });
                dbt-core = super.dbt-core.overridePythonAttrs (o: {
                    pythonRelaxDeps = (o.pythonRelaxDeps or []) ++ [ "click" ];
                });
            };
        };

        # withAdapters, not python.withPackages -- the adapters are namespace
        # packages and collide on dbt/__init__.py in a plain buildEnv.
        dbt-env = (python.pkgs.toPythonApplication python.pkgs.dbt-core)
            .withAdapters (ps: [ ps.dbt-postgres ]);
    in {
        # Expose only bin/dbt; the env also carries bin/python3, which would
        # collide with the python aspect in python.nix.
        environment.systemPackages = [
            (pkgs.runCommand "dbt" { } ''
                mkdir -p $out/bin
                ln -s ${dbt-env}/bin/dbt $out/bin/dbt
            '')
        ];
    };
}
