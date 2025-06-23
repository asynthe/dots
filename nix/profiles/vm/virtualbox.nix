{ config, lib, ... }:
with lib; with types;
let
    cfg = config.meta.vm.virtualbox;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.vm.virtualbox.enable = mkEnableOption "Enable VirtualBox.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {
        
        users.extraGroups.vboxusers.members = [ "${config.meta.system.user}" ];
        virtualisation.virtualbox = {
            host = {
                enable = true;
                #headless = ;
                #enableWebService = ;
                #addNetworkInterface = ; # Sets up vboxnet0
            };
        };

        # The next options require recompilation and nixpkgs.config.allowUnfree = true.

        # Required to forward usb2/usb3 to guests.
        #virtualisation.virtualbox.host.enableExtensionPack = true; 

        # Guest Additions, both need to be enabled.
        #virtualisation.virtualbox.guest.enable = true; 
    };
}
