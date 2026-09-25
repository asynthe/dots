{ ... }:
let
    tx02 = { pkgs, ... }: pkgs.stdenvNoCC.mkDerivation {
        pname = "tx-02";
        version = "unstable";
        src = ../../../assets/fonts/TX-02.zip;
        nativeBuildInputs = [ pkgs.unzip ];
        unpackPhase = "unzip -q $src -d .";
        installPhase = ''
            mkdir -p $out/share/fonts/opentype
            find . -iname '*.otf' -exec cp {} $out/share/fonts/opentype/ \;
        '';
    };
in {
    flake.modules.darwin.fonts = { pkgs, ... }: {
        fonts.packages = [ (tx02 { inherit pkgs; }) pkgs.nerd-fonts.jetbrains-mono ];
    };
}
