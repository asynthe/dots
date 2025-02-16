{
    /*
    A main import of all the options.
    So I can disable or enable them in a modular way.
    */

    imports = [ 
        # -------------- Cache --------------
        ./cache.nix

        # -------------- Audio --------------
        ./audio/bluetooth.nix
        ./audio/musnix.nix
        ./audio/pipewire.nix

        # -------------- Bootloader --------------
        ./boot/banner.nix
        ./boot/bootloader.nix
        ./boot/cleantmp.nix
        ./boot/console.nix
        ./boot/secure.nix
        ./boot/silent.nix

        # -------------- Drivers --------------
        ./driver/displaylink.nix
        ./driver/nvidia.nix

        # -------------- Disk configuration --------------
        ./disk/device.nix
        ./disk/encryption.nix
        ./disk/filesystem.nix
        ./disk/persistence.nix

        # -------------- Gaming --------------
        ./gaming/controller.nix
        ./gaming/gamemode.nix
        ./gaming/steam.nix

        # -------------- Nix Settings --------------
        ./nix/settings.nix

        # -------------- Services --------------
        ./services/android.nix
        ./services/docker.nix
        #./services/endlessh.nix
        ./services/flatpak.nix
        ./services/grafana.nix
        ./services/i2pd.nix
        ./services/locate.nix
        ./services/qbittorrent-nox.nix
        ./services/sql.nix
        ./services/ssh.nix
        ./services/sshfs.nix
        ./services/syncthing.nix
        ./services/wine.nix
        ./services/xmr.nix

        # -------------- System --------------
        ./system/configuration.nix
        ./system/keyboard.nix
        ./system/language.nix
        ./system/networking.nix
        ./system/pkgs.nix
        ./system/user.nix
        ./system/windows.nix

        # -------------- Virtual Machines --------------
        ./vm/libvirt.nix
        ./vm/virtualbox.nix
        ./vm/vmware.nix

        # -------------- VPN --------------
        ./vpn/mullvad.nix
        #./vpn/openvpn.nix
        #./vpn/wireguard.nix
    ];
}
