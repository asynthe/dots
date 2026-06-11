{ config, pkgs, ... }: {
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
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
    };

    environment.systemPackages = with pkgs; [
        nvtopPackages.full
    ];
}
