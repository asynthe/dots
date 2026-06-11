{ pkgs, ... }: {

    services.xserver.videoDrivers = [ "modesetting" ]; # "intel" -> for older hw

    environment.sessionVariables = { 
        LIBVA_DRIVER_NAME = "iHD"; # optional
    };

    hardware.cpu.intel.npu.enable = true; # TODO meta.cpu.intel.npu
    hardware.cpu.intel.updateMicrocode = true; # TODO meta.cpu.intel.enable
    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ 
            intel-compute-runtime
            intel-media-driver 
            nvidia-vaapi-driver
        ];
    };

    environment.systemPackages = with pkgs; [
        intel-gpu-tools
        libva-utils
    ];
}
