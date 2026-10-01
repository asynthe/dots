{ config, ... }:
{
    flake.modules.nixos.host-p1 = { pkgs, ... }: {

        imports = with config.flake.modules.nixos; [
            profile-laptop
            p1-hardware p1-disko

            impermanence
            laptop
            audio bluetooth colord controller android hhkb
            intel-gpu nvidia-prime
            firmware fingerprint tpm

            tailscale mullvad mullvad-tailscale
            syncthing share
            net-tools soc-tools pentest
            wazuh-syslog

            hyprland hyprglass autologin
            quickshell
            terminals desktop-apps firefox
            fonts theme xdg ime

            python javascript
            database database-gui postgres-local dbt
            infra vscodium
            web-dev work
            virtualisation

            codex claude-code opencode hermes

            steam wine lutris
            osu-lazer stepmania
            star-citizen star-citizen-cache
            retroarch dolphin cemu azahar ppsspp pcsx2 rpcs3
            eden ryubing xenia emulation-station
            uzdoom

            flatpak gimp kiwix monero qbittorrent
            irc music tectonic typst
        ];

        system.nixos.label = "p1";
        system.name = "p1";
        networking.hostName = "p1";
        system.stateVersion = "25.05";
        time.timeZone = "America/Santiago";

        sys.user = "meow";
        sys.flake = "/home/meow/git/dots";

        sys.impermanence.folder = "/persist";

        sys.share.mounts = {
            "/home/shared/anime"   = "/home/meow/archive/media/anime";
            "/home/shared/arcade"  = "/home/meow/archive/arcade";
            "/home/shared/book"    = "/home/meow/archive/media/book";
            "/home/shared/games"   = "/home/meow/archive/games";
            "/home/shared/movies"  = "/home/meow/archive/media/movies";
            "/home/shared/music"   = "/home/meow/archive/media/music";
            "/home/shared/roms"    = "/home/meow/archive/roms";
            "/home/shared/series"  = "/home/meow/archive/media/series";
            "/home/shared/youtube" = "/home/meow/archive/media/youtube";
        };

        sys.wazuh.syslogTarget = "192.168.1.142";

        sys.gpu.intelBusId  = "PCI:0:2:0";
        sys.gpu.nvidiaBusId = "PCI:1:0:0";

        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.supportedFilesystems = [ "btrfs" "vfat" ];
        boot.kernelParams = [
            "i915.enable_psr=0"
            "video=DP-1:d"
        ];
    };
}
