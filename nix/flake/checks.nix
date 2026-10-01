{ config, lib, ... }:
{
    perSystem = { system, ... }: {
        checks = lib.mapAttrs'
            (name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel)
            (lib.filterAttrs
                (_: host: host.config.nixpkgs.hostPlatform.system == system)
                config.flake.nixosConfigurations);
    };
}
