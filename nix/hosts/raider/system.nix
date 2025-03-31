{ config, lib, pkgs, ... }: {

    # TODO Remember to make the modules options once working.
    imports = [ ../../modules ];
        
    programs.xwayland.enable = true; # TODO MOVE -> Hyprland

    # TODO Move to option
    # ------------------- Bleeding Edge -------------------
    nix.package = pkgs.nixVersions.latest;
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;

    # -------------------- System Information --------------------
    networking.hostName = "raider";
    system.stateVersion = "24.11";
    nixpkgs.config.allowUnfree = true;
    networking.networkmanager.enable = true;
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Santiago";

    meta = {
        # -------------- Cache --------------
        cache.nvidia = true; # Cuda mantainers cachix, ENABLE FIRST
                             # then enable the main option.

        # -------------- System - Main --------------
        system.user = "meow";
        system.type = "laptop"; # laptop, server
        system.language = "both"; # english, japanese, both
        system.packages = "minimal"; # minimal, minimal_stable
        system.keyboard = true;

        system.windows.enable = true; # Option for dual-boot, fix System time
        system.windows.disk = "/dev/nvme0n1p2";
        
        # Next options are set up by `meta.system.type`, but can be edited.
        #system.nix.settings = "laptop";
        #system.networking.type = "laptop";
        #system.users = "laptop";

        # -------------- Boot --------------
        boot.bootloader = "systemd-boot";
        #boot.banner = "simple_cat"; # simple_cat, hentai
        boot.generations = 3;
        #boot.cleantmp = true;
        boot.silent = false;
        #boot.secure = true; # Secure Boot (lanzaboote)

        # -------------- Driver --------------
        #driver.displaylink = true;
        #driver.nvidia.specialisation = true; # gaming mode and portable mode.
        driver.nvidia.enable = true;
        driver.nvidia.mode = "offload"; # offload, sync
        driver.nvidia.bus_id.intel_cpu = "PCI:1:0:0";
        driver.nvidia.bus_id.nvidia_gpu = "PCI:0:2:0";

        # -------------- Audio --------------
        audio.bluetooth = true;
        #audio.musnix = false;
        audio.pipewire.enable = true;
        #audio.pipewire.lowlatency = false;

        # -------------- Gaming --------------
        gaming.steam = true;
        gaming.gamemode = true;
        #gaming.controller = true;

        # -------------- Services --------------
        services.android.enable = true;
        services.docker.enable = true;
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

        # -------------- VM --------------
        vm.libvirt.enable = true;
        #vm.virtualbox.enable = true;
        vm.vmware.enable = true;

        # -------------- VPN --------------
        vpn.mullvad.enable = true;

        # -------------- Services - Ports --------------
        #services.ssh.port = 2001;
        #services.grafana.port = 2002;
        #services.service1.port = 2002;
        #services.service2.port = 2002;
    };
}
