{
    imports = [
        # Setup
        ./impermanence.nix
        ./lanzaboote.nix # -> boot.nix (?)
        ./tpm.nix # -> cpu.nix (?)
        ./intel.nix # -> cpu.nix (?)
        ./nvidia.nix # -> gpu.nix (?)

        # Environment
        ./hyprland.nix
        ./greetd.nix
        ./laptop.nix # make custom option custom.laptop (?)

        ./android.nix
        ./bluetooth.nix
        ./controller.nix # ps5 controller
        ./docker.nix
        ./fonts.nix
        ./fprintd.nix # fingerprint
        ./gimp.nix
        ./ime.nix
        ./kiwix.nix
        ./kubernetes.nix
        ./minecraft.nix
        ./mullvad-vpn.nix
        ./nvim-nvf.nix
        ./opencode.nix
        ./paraview.nix
        ./password-store.nix
        ./qbittorrent.nix # ps3
        ./rpcs3.nix # ps3
        ./steam.nix
        ./syncthing.nix
        ./tailscale.nix
        ./tectonic.nix
        ./terraform.nix
        ./typst.nix
        ./vm.nix # vmware, libvirt, virt-manager
        ./wine.nix
        ./xenia.nix # xbox 360
    ];
}
