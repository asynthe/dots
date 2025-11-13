{ pkgs, ... }: {

    # ───────────────────────── Fonts - Japanese ─────────────────────────
    fonts.packages = with pkgs; [
        ipafont
        kochi-substitute
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        sarasa-gothic
    ];
}
