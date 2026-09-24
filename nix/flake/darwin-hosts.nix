{ config, lib, inputs, ... }:
let
    prefix = "host-";

    hostAspects = lib.filterAttrs
        (name: _: lib.hasPrefix prefix name)
        config.flake.modules.darwin;

    mkHost = name: module: lib.nameValuePair
        (lib.removePrefix prefix name)
        (inputs.nix-darwin.lib.darwinSystem {
            specialArgs = { inherit inputs; };
            modules = [ module ];
        });
in {
    flake.darwinConfigurations = lib.mapAttrs' mkHost hostAspects;
}
