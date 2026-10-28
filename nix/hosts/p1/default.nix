{ config, ... }:
{
  flake.modules.nixos.host-p1 = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      p1-hardware
      p1-disko

      profile-base
      profile-desktop
      profile-dev
      profile-ai
      profile-gaming
      profile-emulation
      profile-security
      profile-media

      impermanence
      laptop
      zram
      audio
      bluetooth
      colord
      controller
      android
      hhkb
      copilot-key
      intel-gpu
      nvidia-prime
      firmware
      fingerprint
      tpm
      secure-boot

      tailscale
      mullvad
      mullvad-tailscale
      syncthing
      share
    ];

    networking.hostName = "p1";
    system.nixos.label = "p1";
    system.name = "p1";
    system.stateVersion = "25.05";
    time.timeZone = "America/Santiago";

    sys.user = "meow";

    sys.share.mounts = {
      "/home/shared/anime" = "/home/meow/archive/media/anime";
      "/home/shared/arcade" = "/home/meow/archive/arcade";
      "/home/shared/book" = "/home/meow/archive/media/book";
      "/home/shared/games" = "/home/meow/archive/games";
      "/home/shared/movies" = "/home/meow/archive/media/movies";
      "/home/shared/music" = "/home/meow/archive/media/music";
      "/home/shared/roms" = "/home/meow/archive/roms";
      "/home/shared/series" = "/home/meow/archive/media/series";
      "/home/shared/youtube" = "/home/meow/archive/media/youtube";
    };

    sys.wazuh.syslogTarget = "192.168.1.142";

    sys.gpu.intelBusId = "PCI:0:2:0";
    sys.gpu.nvidiaBusId = "PCI:1:0:0";

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [
      "btrfs"
      "vfat"
    ];
    boot.kernelParams = [
      "i915.enable_psr=0"
      "video=DP-1:d"
    ];
  };
}
