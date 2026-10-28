{ config, ... }:
{
  # Emulators and the ES-DE frontend.
  flake.modules.nixos.profile-emulation = {
    imports = with config.flake.modules.nixos; [
      retroarch
      dolphin
      cemu
      azahar
      ppsspp
      pcsx2
      rpcs3
      eden
      ryubing
      xenia
      emulation-station
    ];
  };
}
