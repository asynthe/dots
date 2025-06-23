{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.vm.vmware;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.vm.vmware.enable = mkEnableOption "Enable vmware.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        services.xserver.videoDrivers = [ "vmware" ];
        virtualisation.vmware = {
            host = {
                enable = true;
	            #package = pkgs.vmware-workstation;
                #extraPackages = with pkgs; [ ntfs3g ];
	            #extraConfig = ;
	        };
	        guest = {
                enable = true; # Guest additions
	            #headless = true;
	        };
        };

        environment.systemPackages = with pkgs; [
            open-vm-tools
        ];
 
        # `vmware-vmx` will cause kcompactd0 due to `Transparent Hugepages` feature in kernel.
        # Apply the next to disable it.
        #boot.kernelParams = [ "transparent_hugepage=never" ];
    };
}
