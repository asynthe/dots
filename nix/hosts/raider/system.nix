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

        system.windows.enable = true; # Option for dual-boot, fix System time
        system.windows.disk = "/dev/nvme0n1p2";
        
        # Next options are set up by `meta.system.type`, but can be edited.
        #system.nix.settings = "laptop";
        #system.networking.type = "laptop";
        #system.users = "laptop";

        # Package set
        system.packages = "minimal"; # minimal, minimal_stable, hyprland

        # ─────────────── Boot ───────────────
        boot.kernel = "zen"; # latest, zen, hardened
        #boot.banner = "simple_cat"; # simple_cat, hentai
        #boot.cleantmp = true;
        boot.bootloader.type = "systemd-boot";
        boot.bootloader.generations = 3; # Secure Boot (Lanzaboote)
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
        #driver.nvidia.specialisation = true; # gaming mode and portable mode.
        driver.nvidia.enable = true;
        driver.nvidia.package = "beta"; # stable, beta
        driver.nvidia.mode = "offload"; # offload, sync, reverse-sync
        driver.nvidia.bus_id.intel_cpu = "PCI:1:0:0";
        driver.nvidia.bus_id.nvidia_gpu = "PCI:0:2:0";

        # ─────────────── Audio ───────────────
        audio.bluetooth = true;
        #audio.musnix = false;
        audio.pipewire.enable = true;
        #audio.pipewire.lowlatency = false;

        # ─────────────── Gaming ───────────────
        gaming.steam = true;
        gaming.gamemode = true;
        #gaming.controller = true;
        #gaming.gaming_spec = true; # NOTE Enable gaming specialization based on Jovian NixOS.

        # ─────────────── VM ───────────────
        vm.libvirt.enable = true;
        #vm.virtualbox.enable = true;
        #vm.vmware.enable = true;

        # ─────────────── VPN ───────────────
        vpn.mullvad.enable = true;

        # ─────────────── Services ───────────────
        services.android.enable = true;
        #services.docker.enable = true;
        #services.endlessh.enable = true;
        #services.flatpak.enable = true;
        #services.grafana.enable = true;
        #services.i2pd.enable = true;
        #services.locate.enable = true;
        services.qbittorrent-nox.enable = true;
        #services.sql.enable = true;
        services.ssh.enable = true;
        services.ssh.configuration = "laptop"; # laptop, server
        #services.sshfs.enable = true;
        #services.syncthing.enable = true;
        services.wine.enable = true;
        #services.xmr.enable = true;

        # ─────────────── Services - Ports ───────────────
        #services.ssh.port = 2001;
        #services.grafana.port = 2002;
        #services.service1.port = 2002;
        #services.service2.port = 2002;
    };
}
