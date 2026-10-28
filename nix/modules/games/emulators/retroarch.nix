_: {
  # Cores are exposed at /run/current-system/sw/lib/retroarch/cores, which is
  # where ES-DE's custom find rules (config/ES-DE/custom_systems) look.
  flake.modules.nixos.retroarch = { pkgs, ... }: {
    environment.pathsToLink = [ "/lib/retroarch" ];
    environment.systemPackages = [
      (pkgs.retroarch.withCores (
        c: with c; [
          mesen
          snes9x
          mgba
          mupen64plus
          melondsds
          beetle-psx-hw
          ppsspp
        ]
      ))
    ];
  };
}
