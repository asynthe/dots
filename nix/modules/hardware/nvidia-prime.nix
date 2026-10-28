_: {
  flake.modules.nixos.nvidia-prime = { config, pkgs, ... }: {
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
      intelBusId = config.sys.gpu.intelBusId;
      nvidiaBusId = config.sys.gpu.nvidiaBusId;
    };

    assertions = [
      {
        assertion = config.sys.gpu.intelBusId != "" && config.sys.gpu.nvidiaBusId != "";
        message = "nvidia-prime: set sys.gpu.intelBusId and sys.gpu.nvidiaBusId";
      }
    ];

    environment.systemPackages = with pkgs; [
      nvtopPackages.full
      mesa-demos
    ];
  };
}
