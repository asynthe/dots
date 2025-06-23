# TODO
# FORCE WIREGUARD ON MULLVAD / MULLSCALE ?

{ config, lib, pkgs, ... }:
with lib;
let
    cfg = config.system.vpn;
in {
    # ───────────────────────── Options ─────────────────────────
    options.system.vpn.mullscale = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Tailscale + Mullvad";
        };

        # PACKAGE - system.vpn.mullvad.package = "gui"; (or cli)
        package = mkOption {
            type = types.strings
            default = "mullvad-vpn";
            # pkgs.mullvad only provides the CLI tool.
            # pkgs.mullvad-vpn provices both CLI and GUI.
        };

        # pkgs.mullvad only provides the CLI tool.
        # pkgs.mullvad-vpn provices both CLI and GUI.

        # PERSISTENCE / PERSIST BOTH FILES
        # if system.vpn.mullscale = true;
        # and if environment.persist = true; # FIND
        # then system.vpn.mullsacale.persist = true;
        # Can be disabled
        #persist = mkOption {
            #type = 
            #default = false;
            #description = "";
            #environment.persistence.state.files = [ "/etc/mullvad-vpn/device.json" ];
        #};

        # LOCATION
        # tokyo, osaka, melbourne, sydney
        #location = mkOption {
            #type = strings
        #};
    };

    options.system.vpn.mullvad = mkOption {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Mullvad VPN";
        };

        # PACKAGE - system.vpn.mullvad.package = "gui"; (or cli)
        #package = mkOption {
        #};

        # PERSISTENCE - system.vpn.mullvad.persit = true; (or false)
        # if system.vpn.mullvad = true;
        # and if environment.persist = true; # FIND
        # then system.vpn.mullvad.persist = true;
        # Can be disabled
        #persist = mkOption {
            #type = types.bool;
            #default = false;
            #description = "";
            #environment.persistence.state.files = [ "/etc/mullvad-vpn/device.json" ];
        #};

        # LOCATION - system.vpn.mullvad.package = "tokyo"; (or ...)
        # tokyo, osaka, melbourne, sydney
        #location = mkOption {
            #type = strings
        #};
    };

    options.system.vpn.tailscale = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Tailscale";
        };

        #persist = mkOption {
            #type = 
            #default = false;
            #description = "Enable Tailscale + Mullvad";
            # GRAB A CONFIG VAR THAT ENABLES PERSISTENCE = YES
            # mkIf ... then
            #environment.persistence.state.files = [ "/etc/mullvad-vpn/device.json" ];
        #};
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkMerge [
        (mkIf (cfg.mullscale.enable) {
            services.tailscale.enable = true;
            networking.firewall.trustedInterfaces = [ "tailscale0" ];
            # Allow connections through mullvad exit nodes
            #networking.firewall.checkReversePath = "loose"; # ?
            #networking.firewall.trustedInterfaces = [ "tailscale0" ];

            services.mullvad-vpn = {
                enable = true;
                # pkgs.mullvad only provides the CLI tool.
                # pkgs.mullvad-vpn provices both CLI and GUI.
                # GUI also brings the CLI.
                package = pkgs.mullvad-vpn;
            };
            
            # Mullvad configuration
            systemd.services."mullvad-daemon".postStart = 
            let
                mullvad = "${config.vpn.mullvad.package}/bin/mullvad";
                location = toString config.vpn.mullvad.location;
            in ''
              while ! ${mullvad} status >/dev/null; do sleep 1; done
              ${mullvad} lan set allow
              ${mullvad} auto-connect set on
              ${mullvad} lockdown-mode set on
              ${mullvad} relay set location ${location}
            '';
            
            #${if config.services.tailscale.enable then ''
            #${mullvad} split-tunnel add $(pgrep tailscaled) 
            #'' else ""}

            networking.nftables = lib.mkIf config.services.tailscale.enable {
                enable = true;

                # Mullvad and Tailscale will fight to the death over routing rules (and
                # Mullvad will win) unless we set exceptions for Tailscale. Issue link:
                # https://github.com/tailscale/tailscale/issues/925#issuecomment-1616354736.
                tables."mullvad-tailscale" = {
                    family = "inet";
                    content = ''
                    chain prerouting {
                      type filter hook prerouting priority -100; policy accept;
                      ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
                    }

                    chain outgoing {
                      type route hook output priority -100; policy accept;
                      meta mark 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
                      ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
                    }
                    '';
                };
            };
        })

        (mkIf (cfg.mullvad.enable) {
            services.mullvad-vpn = {
                enable = true;
                package = toPackage config.system.vpn.mullvad.package;
            };

            systemd.services."mullvad-daemon".postStart = 
            let
                mullvad = "${config.services.mullvad.package}/bin/mullvad";
                location = toString config.vpn.mullvad.location;
            in ''
              while ! ${mullvad} status >/dev/null; do sleep 1; done
              ${mullvad} lan set allow
              ${mullvad} auto-connect set on
              ${mullvad} lockdown-mode set on
              ${mullvad} relay set location ${location}
            '';
        })

        (mkIf cfg.tailscale.enable) {
            services.tailscale.enable = true;
            networking.firewall.trustedInterfaces = [ "tailscale0" ];
        })
    ];
}

        #sops.secrets.mullvadAccount = {
            #sopsFile = ./secrets.yaml;
            #path = "/etc/mullvad-vpn/account-history.json";
        #};

        # Mullvad as a package
        #environment.systemPackages = builtins.attrValues {
            #inherit (pkgs)
                #mullvad # CLI
                #mullvad-vpn # GUI
            #;
        #};

        # Mullvad as a service
        #services.mullvad-vpn.enable = true;
        #networking = {
            #iproute2.enable = true;
            #firewall.checkReversePath = "loose";
            #wireguard.enable = true;
        #};
    
    # -------------------------------------------------
    # Tailscale

    #services.tailscale.enable = true;
    #networking.firewall = {
        #trustedInterfaces = [ "tailscale0" ];
        #checkReversePath = "loose"; # TEST - Allow connections through mullvad exit nodes
    #};

    # -------------------------------------------------

    # IMPLEMENT SECRET
    #sops.secrets.mullvadAccount = {
        #sopsFile = ./secrets.yaml;
        #path = "/etc/mullvad-vpn/account-history.json";
    #};

    # Mullvad configuration
    #systemd.services."mullvad-daemon".postStart = 
    #let
        #mullvad = "${config.services.mullvad-vpn.package}/bin/mullvad";
        #location = "au-mel-wg-301";
    #in ''
#while ! ${mullvad} status >/dev/null; do sleep 1; done
#${mullvad} lan set allow
#${mullvad} auto-connect set on
#${mullvad} lockdown-mode set on
#${mullvad} relay set location ${location}
    #'';
#${if config.services.tailscale.enable then ''
#${mullvad} split-tunnel add $(pgrep tailscaled) 
#'' else ""}

    #networking.nftables = lib.mkIf config.services.tailscale.enable {
        #enable = true;

        # Mullvad and Tailscale will fight to the death over routing rules (and
        # Mullvad will win) unless we set exceptions for Tailscale. Issue link:
        # https://github.com/tailscale/tailscale/issues/925#issuecomment-1616354736.
        #tables."mullvad-tailscale" = {
            #family = "inet";
            #content = ''
#chain prerouting {
  #type filter hook prerouting priority -100; policy accept;
  #ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
#}

#chain outgoing {
  #type route hook output priority -100; policy accept;
  #meta mark 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
  #ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
#}
            #'';
        #};
    #};
