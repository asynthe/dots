{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.nvidia;
in {
    options.sys.modules.nvidia = {
        enable = lib.mkEnableOption "Nvidia";
    };

    config = lib.mkIf cfg.enable {
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics = {
            enable = true;
            enable32Bit = true;
        };

        hardware.nvidia = {
            modesetting.enable = true;
            nvidiaSettings = true;
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.production;
        };

        hardware.nvidia.prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            # TODO See how to make this option or get it from a command
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
        };

        environment.systemPackages = with pkgs; [
            nvtopPackages.full
        ];
    };
}
