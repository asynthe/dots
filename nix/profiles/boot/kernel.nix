# TODO Create 'custom' in the future (?)

{ config, lib, pkgs, ... }:
with lib; with types;
let
cfg = config.meta.boot;
in {
    options.meta.boot.kernel = mkOption {
        type = enum [ "latest" "zen" "hardened" ];
        default = "latest";
        description = "Linux kernel to use.";
    };

    config = mkMerge [
        # Latest
        (mkIf (cfg.kernel == "latest") { 
            boot.kernelPackages = mkForce pkgs.linuxKernel.packages.latest;
         })

        # zen
        (mkIf (cfg.kernel == "zen") { 
            boot.kernelPackages = mkForce pkgs.linuxKernel.packages.linux_zen;
        })

        # Hardened
        (mkIf (cfg.kernel == "hardened") { 
            boot.kernelPackages = mkForce pkgs.linuxKernel.packages.hardened;
        })
    ];
}
