{ ... }:
{
    flake.modules.nixos.intel-gpu = { pkgs, ... }: {
        services.xserver.videoDrivers = [ "modesetting" ];
        hardware.cpu.intel.updateMicrocode = true;

        hardware.cpu.intel.npu.enable = true;
        hardware.graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                intel-compute-runtime
                intel-media-driver
            ];
        };

        environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "iHD";
        };

        environment.systemPackages = with pkgs; [
            intel-gpu-tools
            libva-utils
        ];
    };
}
