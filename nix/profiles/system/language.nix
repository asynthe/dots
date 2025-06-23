{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.system;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.system.language = mkOption {
        type = str;
        default = "english";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = let
        choices = {
            # Both (English and Japanese)
            both = {
                defaultLocale = "en_US.UTF-8";
                supportedLocales = [
                    "en_US.UTF-8/UTF-8"
                    "ja_JP.UTF-8/UTF-8"
                    "ja_JP.EUC-JP/EUC-JP"
                ];
            };

            # English
            english = {
                defaultLocale = "en_US.UTF-8";
                #extraLocaleSettings = {
                    # Set up here custom locale settings.
                #};
            };

            # 日本語
            japanese = {
                defaultLocale = "ja_JP.UTF-8";
                supportedLocales = [
                    "en_US.UTF-8/UTF-8"
                    "ja_JP.EUC-JP/EUC-JP"
                ];
                #extraLocaleSettings = {
                    #LC_ALL = "ja_JP.UTF-8"; # This one overrides all.
                #};
            };
        };

    in mkIf (cfg.language != null) {
        i18n = choices.${cfg.language};

        # 東京の時間 - Tokyo timezone.
        time.timeZone = mkIf (cfg.language == "japanese") "Asia/Tokyo";
    };
}
