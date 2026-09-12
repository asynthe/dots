# Thinkpad P1 Gen 7, the primary laptop. Declaring `host-p1` is the whole registration.
{ config, ... }:
{
    flake.modules.nixos.host-p1 = { pkgs, ... }: {

        imports = with config.flake.modules.nixos; [
            core cli
            p1-hardware p1-disko

            # ─────────────── System ───────────────
            boot boot-silent
            impermanence
            laptop
            audio bluetooth colord controller android
            intel-gpu nvidia-prime
            firmware fingerprint tpm
            gpg pass sops

            # ─────────────── Network ───────────────
            network tailscale mullvad mullvad-tailscale
            ssh syncthing
            net-tools soc-tools pentest
            wazuh-syslog

            # ─────────────── Desktop ───────────────
            hyprland hyprglass autologin
            quickshell quickshell-tide-island
            terminals desktop-apps
            fonts theme xdg ime

            # ─────────────── Dev ───────────────
            git neovim
            python javascript
            terraform vscodium
            web-dev work
            deploy-rs
            virtualisation

            # ─────────────── AI ───────────────
            claude-code opencode hermes

            # ─────────────── Gaming ───────────────
            steam wine lutris
            osu-lazer stepmania
            star-citizen star-citizen-cache
            eden ryubing pcsx2 xenia emulation-station
            uzdoom

            # ─────────────── Apps ───────────────
            atuin flatpak gimp kiwix monero qbittorrent
            irc music tectonic typst nh
        ];

        # ─────────────── Identity ───────────────
        system.nixos.label = "p1";
        system.name = "p1";
        networking.hostName = "p1";
        system.stateVersion = "25.05";
        time.timeZone = "America/Santiago";

        sys.user = "meow";
        sys.flake = "/home/meow/git/dots";

        sys.impermanence.folder = "/persist";

        sys.gpu.intelBusId  = "PCI:0:2:0";
        sys.gpu.nvidiaBusId = "PCI:1:0:0";

        sys.ssh.authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24"
        ];

        # ─────────────── Kernel ───────────────
        boot.kernelPackages = pkgs.linuxPackages_latest; # pkgs.linuxPackages_zen;
        boot.supportedFilesystems = [ "btrfs" "vfat" ];
        boot.kernelParams = [ "i915.enable_psr=0" ]; # works around internal panel blanking bug
    };
}
