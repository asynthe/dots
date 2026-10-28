{ inputs, ... }:
{
  flake.modules.nixos.wine =
    { pkgs, ... }:
    let
      wine-staging =
        inputs.nixpkgs-wine.legacyPackages.${pkgs.stdenv.hostPlatform.system}.wineWow64Packages.staging;
    in
    {
      environment.systemPackages = [
        wine-staging
      ]
      ++ (with pkgs; [
        winetricks
        mono
        wineWow64Packages.waylandFull
        wineWow64Packages.fonts
      ]);
    };
}
