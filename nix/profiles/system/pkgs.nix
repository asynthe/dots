{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.system;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.system.packages = mkOption {
        type = str;
        default = "minimal";
        description = "Set of packages to install by default.";
    };

    imports = [
        # Always on
        ../../pkgs/set/minimal.nix

        # wm-on / graphics on / no server
        ../../pkgs/set/fonts.nix
        ../../pkgs/set/minimal.nix
        ../../pkgs/set/wm.nix

        #../../pkgs/set/networking.nix
        #../../pkgs/set/wsl.nix
        #../../pkgs/set/games.nix
        #../../pkgs/set/sec.nix
    ];

    # ───────────────────────── Configuration ─────────────────────────
    # ...
}
