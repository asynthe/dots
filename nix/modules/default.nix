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
        ./atuin.nix
        ./bluetooth.nix
        ./colord.nix
        ./controller.nix # ps5 controller
        ./docker.nix
        ./flatpak.nix
        ./fonts.nix
        ./fprintd.nix # fingerprint
        ./gimp.nix
        ./git.nix
        ./ime.nix
        ./kiwix.nix
        ./kubernetes.nix
        ./minecraft.nix
        ./mullvad-vpn.nix
        ./networking.nix
        ./nvim-nvf.nix
        ./openclaw.nix
        ./opencode.nix
        ./paraview.nix
        ./password-store.nix
        ./qbittorrent.nix
        ./ssh.nix
        ./steam.nix
        ./syncthing.nix
        ./tailscale.nix
        ./tectonic.nix
        ./terraform.nix
        ./typst.nix
        ./vm.nix # vmware, libvirt, virt-manager
        ./vscodium.nix
        ./wine.nix
        ./xdg.nix
        ./xenia.nix # xbox 360
    ];
}
