{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.typst;
in {
    options.sys.modules.typst = {
        enable = lib.mkEnableOption "Typst";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            typst

            # fonts
            et-book
            garamond-libre
            nerd-fonts.zed-mono
        ];
    };
}
