{ config, lib, pkgs, ... }: {

    # ───────────────────────── System Information ─────────────────────────
    networking.hostName = "raider";
    system.stateVersion = "24.11";
    system.nixos.label = "meowsito";
    nixpkgs.config.allowUnfree = true;
    networking.networkmanager.enable = true;
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Asia/Tokyo";

    meta = {
        # ─────────────── System - Main ───────────────
        system.user = "meow";
        system.type = "laptop"; # laptop, server
        system.language = "both"; # english, japanese, both
        system.keyboard = true;
        system.dark-mode = true;
        system.windows = true;

        # Next options are set up by `meta.system.type`, but can be edited.
        #system.nix.settings = "laptop";
        #system.networking.type = "laptop";
        #system.users = "laptop";

        # Package set
        system.packages = "minimal"; # minimal, minimal_stable, hyprland

        # ─────────────── Audio ───────────────
        audio.bluetooth.enable = true;
        audio.bluetooth.no_handsfree_mode = true;
        audio.musnix.enable = false;
        audio.pipewire.enable = true;
        audio.pipewire.low-latency = false;

        # ─────────────── Boot ───────────────
        boot.kernel = "zen"; # latest, zen, hardened
        #boot.banner = "simple_cat"; # simple_cat, hentai
        #boot.cleantmp = true;
        boot.bootloader.type = "systemd-boot";
        boot.bootloader.generations = 3;
        boot.bootloader.secure = false; # Secure Boot (Lanzaboote)
        boot.bootloader.silent = true;

        # ─────────────── Disk ───────────────
        disk.device = "/dev/nvme0n1";
        disk.filesystem = "btrfs"; # bcachefs, btrfs, ext4, xfs, zfs
        disk.ssd = true;

        # Encryption (luks)
        disk.encryption.enable = true;
        disk.encryption.message = "cat"; # cat, dice
        #disk.encryption.device_name = "encrypted";

        # Swap
        #disk.swap.enable = true;
        #disk.swap.size = "16G";

        # Persistence
        disk.persistence.enable = true;
        #disk.persistence.type = "tmpfs"; # snapshots (btrfs) or tmpfs

        # ─────────────── Driver ───────────────
        #driver.displaylink = true;
        driver.nvidia.enable = true;
        driver.nvidia.package = "beta"; # stable, beta
        driver.nvidia.mode = "offload"; # offload, sync, reverse-sync
        #driver.nvidia.specialisation = true; # sync, offload
        driver.nvidia.bus_id.intel_cpu = "PCI:1:0:0";
        driver.nvidia.bus_id.nvidia_gpu = "PCI:0:2:0";

        # ─────────────── Gaming ───────────────
        gaming.steam = true;
        gaming.gamemode = true;
        #gaming.controller = true;
        #gaming.gaming_spec = true; # NOTE Enable gaming specialization based on Jovian NixOS.

        # ─────────────── VM ───────────────
        vm.libvirt.enable = true;
        vm.virtualbox.enable = false;
        vm.vmware.enable = false;

        # ─────────────── VPN ───────────────
        vpn.mullvad.enable = true;

        # ─────────────── Services ───────────────
        services.android.enable = true;
        services.clamav.enable = true;
        services.endlessh.enable = false;
        services.flatpak.enable = false;
        services.grafana.enable = false;
        services.i2pd.enable = false;
        services.kiwix.enable = true;
        services.locate.enable = false;
        services.monica.enable = false;
        services.ollama.enable = false;
        services.qbittorrent-nox.enable = false;
        services.radicale.enable = true;
        services.sql.enable = false;
        services.ssh.configuration = "laptop"; # laptop, server
        #services.sql.backend = [ "mysql" "postgresql" ];
        services.ssh.enable = true;
        services.sshfs.enable = false;
        services.syncthing.enable = true;
        services.vdirsyncer.enable = true;
        services.wine.enable = false;
        services.xmr.enable = true;

        # ─────────────── Services - Ports ───────────────
        # TODO
        # Check which services have port option.
        #services.ssh.port = 2001;
        #services.grafana.port = 2002;
        #services.syncthing.port = 2003;
        #services.kiwix.port = 2003;

        # ─────────────── Docker + Containers ───────────────
        services.docker.enable = true;
        services.docker.containers.monica.enable = true;
        services.docker.containers.monica.dir = "/tmp/monica";
        services.docker.containers.prowlarr.enable = false;
        services.docker.containers.radarr.enable = false;
        services.docker.containers.sonarr.enable = false;
    };
}
