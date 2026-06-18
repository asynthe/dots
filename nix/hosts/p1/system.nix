/*   
TODO The thing is most of systems shouldn't have to be multiple options
But it's the name of the host that makes the system with a specific configuration

TODO A module `ssh` should only have ssh configuration
Here there should be a ssh-keys with a mkIf, so it automatically build
This file is for this system specific configuration

TODO Set up secrets agenix or sops-nix, same as before, there's a workign
"base" config, and we can get a good `laptop` but some specific stuff
should use that agenix ssh key or something
*/

{ pkgs, ... }:
let
    user = "meow";
in {
    # ─────────────── System ───────────────
    system.name = "p1";
    system.nixos.label = "p1";
    networking.hostName = "p1";
    system.stateVersion = "25.05";
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Santiago";
    boot.kernelPackages = pkgs.linuxPackages_latest; # pkgs.linuxPackages_zen;
    services.fstrim.enable = true;

    # TODO Remove once rpcs3 works or see if would be good to optionize (zram and zswap?)
    # zram swap for memory-hungry builds (rpcs3 linker needs ~14GB+)
        #zramSwap = {
        #enable = true;
        #memoryPercent = 50;
    #};

    # Nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.warn-dirty = false;

    # Boot loader
    boot = {
        supportedFilesystems = [ "btrfs" "vfat" ];

        # Silent Boot
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
            "splash"
            "quiet"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
            "video=1920x1200"
        ];
    };

    # Shell
    programs.zsh.enable = true;
    users.users.${user} = {
        shell = pkgs.zsh;
        isNormalUser = true;
        initialPassword = "meows123";
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

    # Audio - Pipewire
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        audio.enable = true; # Use as primary sound server
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
    };

    # ─────────────── Modules ───────────────
    sys = {
        #disk.disk0 = "/dev/nvme0n1"; # TODO ASSERTION, ATLEAST ONE OF THIS SHOULD BE MANDATORY
        #disk.disk1 = "/dev/nvme1n1";
        # disk = {
        #   raid0 = "" # mirroring
        #   raid1 = true;
        #   raid2 = true;
        #   raid3 = true;
        #   raid4 = true;
        #   raid5 = true;
        #   raid6 = true;
        # };

        # MOVE TO SYSTEM
        #system = {
            #impermanence.enable = true;
            #nvidia.enable = true;
            #intel.enable = true;
        #};

        modules = {
            impermanence.enable = true;
            lanzaboote.enable = true;
            tpm.enable = true;
            intel.enable = true;
            nvidia.enable = true;
            networking.enable = true;

            hyprland.enable = true;
            greetd.enable = true;
            laptop.enable = true;

            android.enable = true;
            atuin.enable = true;
            bluetooth.enable = true;
            colord.enable = true;
            controller.enable = true; # ps5 controller
            docker.enable = true;
            flatpak.enable = true;
            fonts.enable = true;
            fprintd.enable = true;
            gimp.enable = true;
            git.enable = true;
            ime.enable = true;
            kiwix.enable = true;
            kubernetes.enable = true;
            minecraft.enable = true;
            monero.enable = true;
            mullvad-vpn.enable = true;
            nvim-nvf.enable = true;
            openclaw.enable = false;
            opencode.enable = true;
            paraview.enable = true;
            password-store.enable = true; # gpg + pass
            qbittorrent.enable = true;
            ssh.enable = true;
            steam.enable = true;
            syncthing.enable = true;
            tailscale.enable = true;
            tectonic.enable = true;
            terraform.enable = true;
            typst.enable = true;
            vm.enable = true; # vmware, libvirt, virt-manager
            vscodium.enable = true;
            wine.enable = true;
            xdg.enable = true;
            xenia.enable = true;
        };
    };

    # mkIf's
    # mkIf config.ssh -> Add public key here
    # users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed ... ];
}
