{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.dev;
in {
    options.sys.modules.dev = {
        python.enable = lib.mkEnableOption "Python data science environment";
    };

    config = lib.mkMerge [
        (lib.mkIf cfg.python.enable {
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
                ]))
            ];
        })
    ];
}
