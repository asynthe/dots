{ ... }:
let
    # assets/fonts/TX-02.zip is the real font every terminal config
    # (ghostty/kitty/alacritty/wezterm) already asks for by family name --
    # on Linux it only exists as a fontconfig alias to JetBrains Mono. This
    # installs the actual font instead of also aliasing it here.
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
