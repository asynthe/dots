_: {
  # Cores are exposed at /run/current-system/sw/lib/retroarch/cores, which is
  # where ES-DE's custom find rules (config/ES-DE/custom_systems) look.
  flake.modules.nixos.retroarch = { pkgs, ... }: {
    environment.pathsToLink = [ "/lib/retroarch" ];
    environment.systemPackages = [
      (pkgs.retroarch.withCores (
        c: with c; [
          mesen # nes
          snes9x # snes
          mgba # gb gbc gba
          mupen64plus # n64
          melondsds # nds
          beetle-psx-hw # psx
          ppsspp # psp
        ]
      ))
    ];
  };
}
