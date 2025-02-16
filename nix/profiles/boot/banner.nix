{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.boot;
in {
    options.meta.boot.banner = mkOption {
        type = nullOr str;
        default = null;
        description = "Enable and specify a banner on device login.";
    };

    config = mkIf (cfg.banner != null) {
        #users.motd = "Today is leg day.";
        environment.etc."issue".source = lib.mkForce (
            if cfg.banner == "simple_cat" then ../../../other/ascii/cat_simple
            #else if cfg.banner == "" then ../banner/ascii/.
            #else if cfg.banner == "" then ../banner/ascii/.
            #else if cfg.banner == "" then ../banner/ascii/.
            else throw "Specified banner is not on the options list."
        );
    };
}
