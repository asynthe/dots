{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.nvidia;
in {
    options.sys.modules.nvidia = {
        enable = lib.mkEnableOption "NVIDIA";
        bus-id = lib.mkOption {
            type        = lib.types.str;
            description = "PCI bus ID of the NVIDIA GPU (e.g. PCI:1:0:0)";
        };
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
            package = config.boot.kernelPackages.nvidiaPackages.latest;
            powerManagement.enable = true;
            powerManagement.finegrained = true;
        };

        hardware.nvidia.prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            intelBusId  = config.sys.modules.intel.bus-id;
            nvidiaBusId = cfg.bus-id;
        };

        environment.systemPackages = with pkgs; [
            nvtopPackages.full
            mesa-demos
        ];
    };
}
