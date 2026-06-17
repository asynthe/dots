{
    imports = [
        ./system.nix
        ./hardware.nix
        #./hardware_qemu.nix
        ../../modules/pkgs/set_cli.nix
        ../../modules/pkgs/work.nix

        # Disk setup
        ../../modules/disko/disko.nix # MDADM RAID0
        ../../modules/impermanence.nix
        ../../modules/lanzaboote.nix # -> boot.nix (?)

        ../../modules/nvidia.nix # -> gpu.nix (?)
        ../../modules/intel.nix # -> cpu.nix (?)
        ../../modules/laptop.nix # make custom option custom.laptop (?)
        ../../modules/tpm.nix # -> cpu.nix (?)
        #../../modules/vm.nix # vmware, libvirt, virt-manager
        ../../modules/fprint.nix # fingerprint

        ../../modules/font.nix
        #../../modules/gimp.nix
        ../../modules/gpg.nix
        ../../modules/greetd.nix
        ../../modules/hyprland.nix
        #../../modules/ime.nix
        #../../modules/kubernetes.nix
        #../../modules/minecraft.nix
        #../../modules/music.nix
        #../../modules/nh.nix
        #../../modules/nvim-nvf.nix
        ../../modules/opencode.nix
        #../../modules/syncthing.nix
        ../../modules/tectonic.nix
	../../modules/rpcs3.nix
	../../modules/qbittorrent.nix
	../../modules/steam.nix
    ];
}
