/*   
TODO The thing is most of systems shouldn't have to be multiple options
But it's the name of the host that makes the system with a specific configuration
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

    # Nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.warn-dirty = false;

    # Boot loader
    boot = {
        # Kernel params
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

        # ASCII art on encryption
        # TODO NOT WORKING
        # TODO Option to choose a specific ascii
        # TODO A markdown file that shows this files inside (to test)
        #initrd.extraFiles."ascii.txt".source = ../../../other/ascii/cat_looking.txt; 
            #initrd.systemd.services.show-ascii = {
            #description = "Show ASCII art before LUKS";
            #wantedBy = [ "cryptsetup-pre.target" ];
            #before = [ "cryptsetup-pre.target" ];
            #unitConfig.DefaultDependencies = false;
            #serviceConfig.Type = "oneshot";
            #script = ''
        #cat /ascii.txt
            #echo ""
        #echo "enter password to decrypt"
            #'';
        #};
        # IF NO SYSTEMD ENABLED ON INITRD
        #initrd.preDeviceCommands = ''
        #    cat /ascii.txt
        #    echo ""
        #    echo "enter password to decrypt"
        #'';
    };

    # Networking
    networking.networkmanager = {
        enable = true;
        ethernet.macAddress = "random";
        wifi.scanRandMacAddress = true;
        wifi.macAddress = "random";
    };

    # SSH
    services.openssh.enable = true;
    #users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... example@email.com" ];     

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

        #disk.disk0 = "/dev/nvme0n1";
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

            hyprland.enable = true;
            greetd.enable = true;
            laptop.enable = true;

            android.enable = true;
            bluetooth.enable = true;
            controller.enable = true; # ps5 controller
            docker.enable = true;
            fonts.enable = true;
            fprintd.enable = true;
            gimp.enable = true;
            ime.enable = true;
            kiwix.enable = true;
            kubernetes.enable = true;
            minecraft.enable = true;
            mullvad-vpn.enable = true;
            nvim-nvf.enable = true;
            opencode.enable = true;
            paraview.enable = true;
            password-store.enable = true; # gpg + pass
            qbittorrent.enable = true;
            rpcs3.enable = false;
            steam.enable = true;
            syncthing.enable = true;
            tailscale.enable = true;
            tectonic.enable = true;
            terraform.enable = true;
            typst.enable = true;
            vm.enable = true; # vmware, libvirt, virt-manager
            wine.enable = true;
            xenia.enable = true;
        };
    };
}
