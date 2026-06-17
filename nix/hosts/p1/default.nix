{
    imports = [

        ./system.nix
        ./hardware.nix
        #./hardware_qemu.nix
        ../../modules

        ../../modules/pkgs/set_cli.nix
        ../../modules/pkgs/work.nix
        ../../modules/disko/disko.nix # MDADM RAID0
        #../../modules/disko/disko.nix # MDADM RAID1
        #../../modules/disko/disko.nix # MDADM RAID0
        #../../modules/disko/disko.nix # MDADM RAID0
    ];
}
