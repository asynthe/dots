{ inputs, ... }:
{
  flake.modules.nixos.star-citizen = { pkgs, ... }: {
    imports = [ inputs.nix-citizen.nixosModules.default ];
    environment.systemPackages = [
      inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher
    ];
  };
}
