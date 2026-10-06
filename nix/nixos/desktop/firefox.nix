{ ... }:
{
    flake.modules.nixos.firefox = { pkgs, ... }: {
        programs.firefox = {
            enable = true;
            autoConfigFiles = [
                "${pkgs.arkenfox-userjs}/user.cfg"
                "${../../../config/firefox/common.cfg}"
            ];
            policies.SearchEngines.Default = "DuckDuckGo";
            policies.ExtensionSettings = builtins.mapAttrs (_: slug: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
                installation_mode = "force_installed";
            }) {
                "{a7589411-c5f6-41cf-8bdc-f66527d9d930}" = "matte-black-red";
                "uBlock0@raymondhill.net"                = "ublock-origin";
                "addon@darkreader.org"                   = "darkreader";
                "jid1-BoFifL9Vbdl2zQ@jetpack"            = "decentraleyes";
                "idcac-pub@guus.ninja"                   = "istilldontcareaboutcookies";
                "{de22fd49-c9ab-4359-b722-b3febdc3a0b0}" = "popup-blocker";
                "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = "auto-tab-discard";
                "tabcenter-reborn@ariasuni"              = "tabcenter-reborn";
                "myallychou@gmail.com"                   = "youtube-recommended-videos";
                "{00000f2a-7cde-4f20-83ed-434fcb420d71}" = "imagus";
                "{6b733b82-9261-47ee-a595-2dda294a4d08}" = "yomitan";
                "{6AC85730-7D0F-4de0-B3FA-21142DD85326}" = "colorzilla";
                "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" = "cookie-editor";
                "wappalyzer@crunchlabz.com"              = "wappalyzer";
                "foxyproxy@eric.h.jung"                  = "foxyproxy-standard";
            };
        };

        environment.systemPackages = [ pkgs.dejsonlz4 ];
    };
}
