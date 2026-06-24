{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.intel;
in {
    options.sys.modules.intel = {
        enable = lib.mkEnableOption "Intel";
        bus-id = lib.mkOption {
            type        = lib.types.str;
            description = "PCI bus ID of the Intel iGPU (e.g. PCI:0:2:0)";
        };
    };

    config = lib.mkIf cfg.enable {
        services.xserver.videoDrivers = [ "modesetting" ]; # "intel" -> for older hw
        hardware.cpu.intel.updateMicrocode = true;

        hardware.cpu.intel.npu.enable = true; # TODO sys.modules.intel.npu
        hardware.graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                intel-compute-runtime
                intel-media-driver
            ];
        };

        environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "iHD"; # Intel VA-API via intel-media-driver
        };

        environment.systemPackages = with pkgs; [
            intel-gpu-tools
            libva-utils
        ];
    };
}
