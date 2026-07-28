/*
TODO The thing is most of systems shouldn't have to be multiple options
But it's the name of the host that makes the system with a specific configuration

*/

{ pkgs, config, ... }: {

    # ─────────────── System ───────────────
    system.name = "p1";

    # TODO
    # Set up a custom name for generations
    system.nixos.label = "p1";

    networking.hostName = "p1";
    system.stateVersion = "25.05";
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Santiago";
    boot.kernelPackages = pkgs.linuxPackages_latest; # pkgs.linuxPackages_zen;
    services.fstrim.enable = true;

    # TODO Optionize zram/zswap for memory-hungry builds (the rpcs3 linker needs ~14GB+)

    # Nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.warn-dirty = false;

    # Boot loader
    boot = {
        supportedFilesystems = [ "btrfs" "vfat" ];
        kernelParams = [ "i915.enable_psr=0" ]; # works around internal panel blanking bug
    };

    # Shell
    programs.zsh.enable = true;
    users.users.${config.sys.user} = {
        shell = pkgs.zsh;
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.user-password.path;
        extraGroups = [ "audio" "networkmanager" "input" "wheel" ];
    };

    # Sudo
    security.sudo.extraConfig = ''
        # Ask for password every 2 hours
        Defaults timestamp_timeout=120
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
    '';

    # Dark mode
    environment.sessionVariables = {
        GTK_THEME = "adw-gtk3-dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";
    };

    # ─────────────── Laptop ───────────────
    powerManagement.enable = true;
    services.thermald.enable = true;
    services.auto-cpufreq.enable = false;
    services.logind.settings.Login = {
        HandleLidSwitch = "suspend";             # on battery
        HandleLidSwitchDocked = "ignore";        # docked (external display)
        HandleLidSwitchExternalPower = "suspend"; # plugged in, no external display
    };

    # ─────────────── Modules ───────────────
    sys = {
        user = "meow";
        secrets = [ "pass" "gpg" "sops" ];
        disk = {
            # TODO Add sys.disk options for filesystem, encryption and disko raid to pick the disko file
            impermanence.enable = true;
            impermanence.folder = "/persist";
        };

        modules = {

            # system
            audio.enable = true;
            boot.enable = true;
            boot.silent = true;
            #boot.secure = true; # +automatic lanzaboote, -systemd-boot
            boot.lanzaboote.enable = false;
            tpm.enable = true;
            intel.enable = true;
            intel.bus-id = "PCI:0:2:0";
            nvidia.enable = true;
            nvidia.bus-id = "PCI:1:0:0";
            networking.enable = true;
            #zram.enable = true;

            # desktop
            desktop.hyprland.enable = true;
            desktop.hyprland.cache = false;
            desktop.autologin.enable = true;
            desktop.autologin.user = config.sys.user;

            # dev + ai
            dev.python.enable = true;
            dev.javascript.enable = true;
            ai.claude-code.enable = true;
            ai.ollama.enable = false;
            ai.ollama.cuda = true;
            ai.ollama.models = [ "qwen3-coder:30b" ];
            ai.openclaw.enable = false;
            ai.opencode.enable = true;

            # gaming
            gaming.enable = true;
            gaming.star-citizen.enable = true;
            gaming.star-citizen.cache = true;
            gaming.eden.enable = true; # switch
            gaming.emulation-station.enable = true;
            gaming.lutris.enable = true;
            gaming.pcsx2.enable = true; # ps2
            gaming.rpcs3.enable = false; # ps3
            gaming.ryubing.enable = true; # switch
            gaming.xenia.enable = true; # x360

            # ssh
            ssh.enable = true;
            ssh.authorizedKeys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24"
            ];

            # modules
            android.enable = true;
            atuin.enable = true;
            bluetooth.enable = true;
            colord.enable = true;
            controller.enable = true; # ps5 controller
            docker.enable = true;
            flatpak.enable = true;
            fonts.enable = true;
            fprintd.enable = true;
            fwupd.enable = true; # firmware updater
            gimp.enable = true;
            git.enable = true;
            ime.enable = true;
            incus.enable = true; # linux containers
            k3s.enable = true; # replaces the broken raw `kubernetes` module below
            kiwix.enable = true;
            kubernetes.enable = false; # fragile easyCerts setup, never came up cleanly
            minecraft.enable = false;
            monero.enable = true;
            mullvad-vpn.enable = true;
            nh.enable = true;
            nvim.enable = true;
            paraview.enable = false;
            qbittorrent.enable = true;
            steam.enable = true;
            syncthing.enable = true;
            tailscale.enable = true;
            tectonic.enable = true;
            terraform.enable = true;
            typst.enable = true;
            vm.enable = true; # libvirt, virt-manager, vmware
            vm.gpu-passthrough = false; # WARNING this will bind the gpu to vfio-pci driver
            vm.vmware = false;
            vscodium.enable = true;
            wine.enable = true;
            xdg.enable = true;
        };
    };
}
