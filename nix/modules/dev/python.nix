_: {
  flake.modules.nixos.python = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.python3.withPackages (
        ps: with ps; [
          numpy
          pandas
          polars
          pyarrow
          scipy

          scikit-learn

          matplotlib
          seaborn
          plotly

          jupyter
          jupyterlab
          ipython

          sqlalchemy
          openpyxl
          requests
          httpx

          black
          ruff
          isort
          mypy

          mutagen
        ]
      ))
    ];
  };
}
