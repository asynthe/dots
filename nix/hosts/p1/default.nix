{ config, ... }:
{
    flake.modules.nixos.host-p1 = { pkgs, ... }: {

        imports = with config.flake.modules.nixos; [
            profile-laptop
            p1-hardware p1-disko

            impermanence
            laptop
            audio bluetooth colord controller android
            intel-gpu nvidia-prime
            firmware fingerprint tpm

            tailscale mullvad mullvad-tailscale
            syncthing share
            net-tools soc-tools pentest
            wazuh-syslog

            hyprland hyprglass autologin
            quickshell
            terminals desktop-apps firefox-clean
            fonts theme xdg ime

            python javascript
            database database-gui postgres-local
            terraform vscodium
            web-dev work
            deploy-rs
            virtualisation

            claude-code opencode hermes

            steam wine lutris
            osu-lazer stepmania
            star-citizen star-citizen-cache
            eden ryubing pcsx2 xenia emulation-station
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
            "/home/kazu/music"   = "/home/meow/archive/media/music";
            "/home/kazu/anime"   = "/home/meow/archive/media/anime";
            "/home/kazu/book"    = "/home/meow/archive/media/book";
            "/home/kazu/movies"  = "/home/meow/archive/media/movies";
            "/home/kazu/series"  = "/home/meow/archive/media/series";
            "/home/kazu/youtube" = "/home/meow/archive/media/youtube";
            "/home/kazu/arcade"  = "/home/meow/archive/arcade";
            "/home/kazu/games"   = "/home/meow/archive/games";
            "/home/kazu/roms"    = "/home/meow/archive/roms";
            "/home/kazu/windows" = "/home/meow/archive/windows";
        };

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
