{
    imports = [

        ./system.nix
        ./hardware.nix
        #./hardware_qemu.nix
        ../../modules/pkgs/set_cli.nix

        # Disk setup
        ../../modules/disko/disko.nix # MDADM RAID0

        # Options
        ../../modules/impermanence.nix
        ../../modules/bluetooth.nix
        ../../modules/controller.nix
        ../../modules/docker.nix
        ../../modules/kubernetes.nix
        ../../modules/mullvad-vpn.nix
        ../../modules/opencode.nix
        ../../modules/password-store.nix
        ../../modules/rpcs3.nix # ps3
        ../../modules/tailscale.nix
        ../../modules/tectonic.nix
        ../../modules/terraform.nix
        ../../modules/typst.nix
        ../../modules/vm.nix # vmware, libvirt, virt-manager
        ../../modules/wine.nix
        ../../modules/xenia.nix # xbox 360

        # Non-optionalized
        ../../modules/non-optionised/lanzaboote.nix # -> boot.nix (?)

        ../../modules/non-optionised/fprint.nix # fingerprint
        ../../modules/non-optionised/intel.nix # -> cpu.nix (?)
        ../../modules/non-optionised/laptop.nix # make custom option custom.laptop (?)
        ../../modules/non-optionised/nvidia.nix # -> gpu.nix (?)
        ../../modules/non-optionised/tpm.nix # -> cpu.nix (?)

        #../../modules/non-optionised/gimp.nix
        #../../modules/non-optionised/minecraft.nix
        #../../modules/non-optionised/syncthing.nix
        ../../modules/non-optionised/font.nix
        ../../modules/non-optionised/greetd.nix
        ../../modules/non-optionised/hyprland.nix
        ../../modules/non-optionised/ime.nix
        ../../modules/non-optionised/music.nix
        ../../modules/non-optionised/nh.nix
        ../../modules/non-optionised/nvim-nvf.nix
        ../../modules/non-optionised/paraview.nix
        ../../modules/non-optionised/phone.nix
        ../../modules/non-optionised/qbittorrent.nix
        ../../modules/non-optionised/steam.nix
    ];
}
