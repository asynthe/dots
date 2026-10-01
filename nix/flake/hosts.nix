{ config, lib, inputs, ... }:
let
    prefix = "host-";

    hostAspects = lib.filterAttrs
        (name: _: lib.hasPrefix prefix name)
        config.flake.modules.nixos;

    mkHost = name: module: lib.nameValuePair
        (lib.removePrefix prefix name)
        (inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ module ];
        });
in {
    flake.nixosConfigurations = lib.mapAttrs' mkHost hostAspects;
}
