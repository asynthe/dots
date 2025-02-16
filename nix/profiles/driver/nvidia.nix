{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.driver.nvidia;
in {
    options.meta.driver.nvidia = {
        enable = mkEnableOption "Enable nvidia driver and configuration";
        specialisation = mkEnableOption "Enable specialisation modes";
        mode = mkOption {
            type = nullOr str;
            default = null;
            description = "Mode for Nvidia PRIME.";
        };
        bus_id = {
            nvidia_gpu = mkOption {
                type = nullOr str;
                default = null;
                description = "Nvidia GPU Bus ID for PRIME.";
            };
            intel_cpu = mkOption {
                type = nullOr str;
                default = null;
                description = "Intel GPU (Integrated) Bus ID for PRIME.";
            };
        };
    };

    config = mkIf cfg.enable {

        assertions = [
            #{
            #    assertion = cfg.enable -> cfg.mode;
            #    message = "Enabling nvidia drivers requires a mode to be enabled.";
            #}
            {
                assertion = cfg.mode != null;
                message = "Please specify a mode (offload/sync) for PRIME.";
            }
        #    {
        #        assertion = cfg.bus_id.nvidia_gpu != null;
        #        message = "Please specify the Bus ID of your Nvidia GPU.";
        #    }
        #    {
        #        assertion = cfg.bus_id.intel_cpu != null;
        #        message = "Please specify the Bus ID of your Intel CPU.";
        #    }
        ];

        # Completely disable NVIDIA graphics and use integrated.
        #hardware.nvidiaOptimus.disable = true;

        # Screen Tearing Issues (Try Prime Sync Mode first, then this option)
        #hardware.nvidia.forceFullCompositionPipeline = true;

        # -------------- Nvidia --------------
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics = {
            enable = mkForce true;
            enable32Bit = mkForce true;

            # Accelerated Video Playback
            extraPackages = with pkgs; [
                nvidia-vaapi-driver
                libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
                libva

                intel-media-driver # VA-API for Intel iHD Broadwell (2014) or newer
                intel-vaapi-driver # VA-API for Intel i965 Broadwell (2014), better for Firefox?
                vaapiVdpau # VDPAU driver for the VAAPI library
            ];
            # For 32-bit, lol. I don't think I'll ever need it.
            #extraPackages32 = with pkgs.pkgsi686Linux; [
                #intel-vaapi-driver
                #vaapiVdpau
                #libvdpau-va-gl
            #];
        };

        hardware.nvidia = {
            modesetting.enable = true; # Required
            nvidiaSettings = true;
            open = true; # Open source kernel module
            #package = pkgs.kernelPackages.nvidiaPackages.stable; # stable, beta...

            # Nvidia power management
            #powerManagement.enable = true;
            #powerManagement.finegrained = false;
        };

        # -------------- Prime --------------
        # Bus ID Values
        # You can find these values by running `lspci | grep ' VGA '`

        # ADD: Make Required!
        hardware.nvidia.prime = {
            intelBusId = cfg.bus_id.intel_cpu;
            nvidiaBusId = cfg.bus_id.nvidia_gpu;
        };

        # -------------- Prime - Offload Mode --------------
        #hardware.nvidia.prime.offload = {
        hardware.nvidia.prime.offload = mkIf (cfg.mode == "offload") {
            enable = true;
            enableOffloadCmd = true;
        };

        # -------------- Prime - Sync Mode --------------
        #hardware.nvidia.prime.sync.enable = true;
        hardware.nvidia.prime.sync.enable = mkIf (cfg.mode == "sync") true;
        
        # -------------- Specialisation --------------
        specialisation = mkIf cfg.specialisation {
        
            # Gaming - Sync
            gaming.configuration = {
                hardware.nvidia.prime = {
                    sync.enable = mkForce true;
                    offload.enable = mkForce false;
                    enableOffloadCmd = mkForce false;
                };
            };
        };

        # -------------- Variables and Packages --------------
        environment = {
            #variables = {
                #GBM_BACKEND = "nvidia-drm";
                #LIBVA_DRIVER_NAME = "nvidia";
                #VDPAU_DRIVER = "va_gl";
                #WLR_NO_HARDWARE_CURSORS = "1";
                #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
            #};

            systemPackages = builtins.attrValues {
                inherit (pkgs)
                    intel-gpu-tools
                    glxinfo # glxgears
                    #glibc
                    #glxinfo # Check if running on gpu.
                    #zenith-nvidia
                    #nvtop-nvidia
                    #vulkan-tools
                    #virtualgl
                    #nvidia-offload
                    #linuxKernel.packages.linux_6_2.bbswitch
                    #libva
                    #libva-utils
                    #libdrm
                    #mesa #mesa-demos
                ;
            };
        };
    };
}
