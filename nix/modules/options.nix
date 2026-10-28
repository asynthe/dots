_: {
  flake.modules.nixos.core =
    { config, lib, ... }:
    {
      options.sys = {
        user = lib.mkOption {
          type = lib.types.str;
          default = lib.head config.sys.admins;
          description = "The seat: which account in auth.nix this machine logs in automatically";
        };

        flake = lib.mkOption {
          type = lib.types.str;
          default = "/home/${config.sys.user}/git/dots";
          description = "Path to this flake, used by nh";
        };

        adminGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra groups every admin in auth.nix joins; aspects append to it";
        };

        gpu = {
          intelBusId = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "PCI bus ID of the Intel iGPU (e.g. PCI:0:2:0)";
          };
          nvidiaBusId = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "PCI bus ID of the NVIDIA GPU (e.g. PCI:1:0:0)";
          };
        };

        impermanence = {
          enable = lib.mkEnableOption "wiping / on boot and persisting to sys.impermanence.folder";
          folder = lib.mkOption {
            type = lib.types.str;
            default = "/persist";
            description = "Path to the persistent storage mountpoint";
          };
        };

        persist = {
          directories = lib.mkOption {
            type = with lib.types; listOf (either str attrs);
            default = [ ];
            description = "Directories kept across reboots; ignored unless impermanence is enabled";
          };
          files = lib.mkOption {
            type = with lib.types; listOf (either str attrs);
            default = [ ];
            description = "Files kept across reboots; ignored unless impermanence is enabled";
          };
        };
      };
    };
}
