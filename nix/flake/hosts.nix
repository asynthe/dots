# A host is just an aspect named `host-<name>`. Declaring one anywhere in the
# tree is the only step needed to get a nixosConfiguration -- nothing else in
# the repo has to learn about it.
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
