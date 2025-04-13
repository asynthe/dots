{ config, pkgs, ... }: {

    fonts = {
        fontconfig.enable = true;
        fontDir.enable = true;
        packages = with pkgs; [
            corefonts
            dejavu_fonts
            liberation_ttf
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-emoji
            nerd-fonts.fira-code
            nerd-fonts.iosevka-term
            nerd-fonts.iosevka-term-slab
            nerd-fonts.jetbrains-mono
            nerd-fonts.mononoki
            nerd-fonts.mplus
            nerd-fonts.overpass
            nerd-fonts.sauce-code-pro
            nerd-fonts.ubuntu-sans
            nerd-fonts.zed-mono
        ];
    };
}
