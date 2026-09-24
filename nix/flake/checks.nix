{ config, lib, ... }:
let
    mkChecks = hosts: system: lib.mapAttrs'
        (name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel)
        (lib.filterAttrs
            (_: host: host.config.nixpkgs.hostPlatform.system == system)
            hosts);
in {
    perSystem = { system, ... }: {
        checks =
            mkChecks config.flake.nixosConfigurations system
            // mkChecks config.flake.darwinConfigurations system;
    };
}
