{ pkgs, ... }: {

    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
            lf
        ;
    };

    programs.bash = {
        shellInit = ''
          lfcd () {
          cd "$(command lf -print-last-dir "$@")"
          }
        '';
        shellAliases = {
            lf = "lfcd";
            rm = "rm -i";
        };
    };
}