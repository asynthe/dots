{ ... }:
{
    flake.modules.nixos.core = { config, lib, ... }: {
        options.sys = {
            user = lib.mkOption {
                type        = lib.types.str;
                default     = lib.head config.sys.admins;
                description = "The seat: which account in auth.nix this machine logs in automatically";
            };

            flake = lib.mkOption {
                type        = lib.types.str;
                default     = "/home/meow/git/dots";
                description = "Path to this flake, used by nh";
            };

            gpu = {
                intelBusId = lib.mkOption {
                    type        = lib.types.str;
                    default     = "";
                    description = "PCI bus ID of the Intel iGPU (e.g. PCI:0:2:0)";
                };
                nvidiaBusId = lib.mkOption {
                    type        = lib.types.str;
                    default     = "";
                    description = "PCI bus ID of the NVIDIA GPU (e.g. PCI:1:0:0)";
                };
            };

            impermanence = {
                enable = lib.mkEnableOption "wiping / on boot and persisting to sys.impermanence.folder";
                folder = lib.mkOption {
                    type        = lib.types.str;
                    default     = "/persist";
                    description = "Path to the persistent storage mountpoint";
                };
            };
        };
    };
}
