{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.system.nix;
in {
    options.meta.system.nix = {
        settings = mkOption {
            type = nullOr (enum [ "laptop" "server" ]);
            default = config.meta.system.type;
            description = "Nix daemon configuration.";
        };
        #cache = mkOption {
            #type = bool;
            #default = true;
        #};
    };

    config = {
        # Hanging at rebuild and wait-online service failing.
        # See nixpkgs#180175
        systemd.services.NetworkManager-wait-online.enable = false;

        # Nix cache and substituters.
        nix.settings = {
            substituters = mkBefore [ "https://cache.nixos.org" ];
            trusted-public-keys = mkBefore [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
        };

        # Settings
        nix.settings = {
            auto-optimise-store = true;
            experimental-features = [ "nix-command" "flakes" ];
            allowed-users = [ "${config.meta.system.user}" ]; # Required for Home Manager
            trusted-users = [ "${config.meta.system.user}" ];
            warn-dirty = false;
        };

        # nh if using laptop configuration
        programs = {
            nh = mkIf (cfg.settings == "laptop") {
                enable = true;
	            clean = {
                    enable = true;
	                extraArgs = "--keep-since 4d --keep 3";
                };
            };
        };

        # Server configuration
        # Garbage collection
        nix.gc = mkIf (cfg.settings == "server") { 
            persistent = true; # Persist if gc is missed.
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 4d";      
	    };

        # Display changes after rebuild.
        # https://discourse.nixos.org/t/how-to-make-nixos-rebuild-output-more-informative/25549/8
        system.activationScripts.diff = mkIf (cfg.settings == "server") ''
          if [[ -e /run/current-system ]]; then
            echo "NixOS system closure diff:"
          ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
          fi
        '';
    };
}
