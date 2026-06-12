{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.intel;
in {
    options.sys.modules.intel = {
        enable = lib.mkEnableOption "Intel";
    };

    config = lib.mkIf cfg.enable {
        services.xserver.videoDrivers = [ "modesetting" ]; # "intel" -> for older hw
        environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD"; # optional
        hardware.cpu.intel.updateMicrocode = true;

        hardware.cpu.intel.npu.enable = true; # TODO sys.modules.intel.npu
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
    };
}
