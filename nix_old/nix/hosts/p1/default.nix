{
    imports = [

        ./system.nix
        ./hardware.nix
        ../../modules

        ../../modules/pkgs/set_cli.nix
        ../../modules/pkgs/soc.nix
        ../../modules/pkgs/web.nix
        ../../modules/pkgs/work.nix
        ../../modules/pkgs/net.nix
        ../../modules/disko/disko.nix # MDADM RAID0
    ];
}
