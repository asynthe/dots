# Thinkpad P1 Gen 7 -- primary laptop.
#
# Declaring `flake.modules.nixos.host-p1` is the whole registration: the
# generator in modules/flake/hosts.nix turns every `host-*` aspect into a
# nixosConfiguration, so nothing else in the repo mentions this machine.
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
            network tailscale mullvad
            ssh syncthing
            net-tools soc-tools

            # ─────────────── Desktop ───────────────
            hyprland autologin
            quickshell
            terminals desktop-apps
            fonts theme xdg ime

            # ─────────────── Dev ───────────────
            git neovim
            python javascript
            terraform vscodium
            web-dev work
            incus virtualisation

            # ─────────────── AI ───────────────
            claude-code opencode

            # ─────────────── Gaming ───────────────
            steam wine lutris
            star-citizen star-citizen-cache
            eden ryubing pcsx2 xenia emulation-station

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
        sys.flake = "/home/meow/dots";

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
