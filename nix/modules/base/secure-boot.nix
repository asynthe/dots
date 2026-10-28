{ inputs, ... }:
{
  flake.modules.nixos.secure-boot =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      # lanzaboote signs its own UKIs and replaces the systemd-boot installer (notes: nix.md, Secure Boot).
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      environment.systemPackages = [ pkgs.sbctl ];

      sys.persist.directories = [ "/var/lib/sbctl" ];
    };
}
