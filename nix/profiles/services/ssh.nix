# TODO
# Configure `config.meta.services.ssh.port`.

{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.services.ssh;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.ssh = {
        enable = mkEnableOption "Enable SSH daemon.";
        configuration = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Configuration for SSH.
            '';
        };
        mosh = mkOption {
            type = bool;
            default = false;
            description = ''
              Enable Mosh, SSH with the UDP Protocol.
            '';
        };
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        programs.mosh.enable = mkIf cfg.mosh true;
        services.openssh = mkMerge [
            {
                enable = true;
            }

            # Laptop
            (mkIf (cfg.configuration == "laptop") { 
                allowSFTP = true;
                #startWhenNeeded = true; # Socket-activated.
                extraConfig = ''
                  PrintlastLog no
                  PrintMotd no
                '';
            })

            # Server
            (mkIf (cfg.configuration == "server") {
	            allowSFTP = true;
                #startWhenNeeded = true; # Socket-activated.
                banner = builtins.readFile ../banner/ssh/server;
                settings = {
                    #PermitRootLogin = "no"; # Messes up with nixos-anywhere.
                    PasswordAuthentication = false;
                    KbdInteractiveAuthentication = false;
                };
                extraConfig = ''
                  PrintlastLog no
                  PrintMotd no
                '';
            })
        ];
    };
}
