{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.flatpak;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.flatpak.enable = mkEnableOption "Enable and set up Flatpak.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.flatpak.enable = true;
        fonts.fontDir.enable = true; # Fix for flatpak not finding system installed fonts.
        xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
            ];
        };
    };
}
