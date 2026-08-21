{ ... }:
{
    flake.modules.nixos.python = { pkgs, ... }: {
        environment.systemPackages = [
            (pkgs.python3.withPackages (ps: with ps; [
                # Core data
                numpy
                pandas
                polars
                pyarrow
                scipy

                # ML
                scikit-learn

                # Viz
                matplotlib
                seaborn
                plotly

                # Notebooks
                jupyter
                jupyterlab
                ipython

                # DB / IO
                sqlalchemy
                openpyxl
                requests
                httpx

                # Tooling
                black
                ruff
                isort
                mypy

                # Music
                mutagen
            ]))
        ];
    };

    flake.modules.nixos.javascript = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            nodejs_22
            yarn
            typescript
            typescript-language-server
            prettierd
            eslint_d
        ];
    };
}
