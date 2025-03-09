{ pkgs, ... }: {

    fonts.packages = builtins.attrValues { inherit (pkgs) meslo-lgs-nf; };
    services.kmscon = {
        enable = true;
        hwRender = true;
        extraConfig = ''
          font-name=MesloLGS NF
          font-size=14
        '';
    };
}
