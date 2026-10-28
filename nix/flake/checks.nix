{ config, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      checks =
        lib.mapAttrs' (name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel) (
          lib.filterAttrs (
            _: host: host.config.nixpkgs.hostPlatform.system == system
          ) config.flake.nixosConfigurations
        )
        // {
          formatting = pkgs.runCommand "nixfmt-check" { nativeBuildInputs = [ pkgs.nixfmt-tree ]; } ''
            cd ${../..}
            treefmt --ci --no-cache --tree-root . && touch $out
          '';
        };
    };
}
